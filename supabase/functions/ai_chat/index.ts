import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const sseHeaders = {
  ...corsHeaders,
  "Content-Type": "text/event-stream; charset=utf-8",
  "Cache-Control": "no-cache, no-transform",
  Connection: "keep-alive",
  "X-Accel-Buffering": "no",
};

const HISTORY_LIMIT = 10;
const TX_LINE_LIMIT = 8;
const TX_QUERY_LIMIT = 100;
const TOP_CATEGORY_LIMIT = 3;
const MAX_MESSAGE_LENGTH = 2000;
const HEARTBEAT_INTERVAL_MS = 15_000;
const HEARTBEAT_COMMENT = "keep-alive";

const SYSTEM_PROMPT = `
You are Walleto AI Assistant, the AI assistant of the Walleto app.

Your job is to help users understand their spending, wallets, categories, and budgeting behavior in a simple, practical, and friendly way.

Rules:
- Keep responses concise, clear, and useful.
- Do not invent balances, transactions, categories, exchange rates, or budgets.
- Only answer from the Walleto data context provided to you.
- If the available data is insufficient, clearly say you do not have enough data.
- Prioritize spending insights, wallet insights, saving suggestions, and budgeting guidance.
- If helpful, suggest one small next action the user can take in the app.
- Mention that you are Walleto AI Assistant naturally when suitable, but do not repeat it unnecessarily.
- You may format answers with simple Markdown: short paragraphs, **bold**, *italic*, inline `code`, and unordered or numbered lists.
- Prefer short paragraphs and lists over long walls of text.
- Do not use tables, images, HTML, or large headings.
- Do not wrap the entire reply in a fenced code block.
`.trim();

type ChatRole = "user" | "assistant";
type SupabaseClient = ReturnType<typeof createClient>;

type UsageTokens = {
  prompt_tokens: number | null;
  completion_tokens: number | null;
  total_tokens: number | null;
};

type FinanceContext = {
  context: string;
  history: Array<{ role: ChatRole; content: string }>;
  debug: {
    base_currency: string;
    wallet_count: number;
    transaction_count: number;
    missing_rate_currencies: string[];
  };
};

const sseEncoder = new TextEncoder();

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function sseFrame(data: unknown) {
  return sseEncoder.encode(`data: ${JSON.stringify(data)}\n\n`);
}

function sseComment(comment: string) {
  return sseEncoder.encode(`: ${comment}\n\n`);
}

function formatMoney(amount: number, currency: string) {
  const safeAmount = Number.isFinite(amount) ? amount : 0;
  return `${new Intl.NumberFormat("vi-VN", {
    maximumFractionDigits: 2,
  }).format(safeAmount)} ${currency}`;
}

function safeNumber(value: unknown) {
  const n = Number(value ?? 0);
  return Number.isFinite(n) ? n : 0;
}

function nullableInt(value: unknown) {
  const n = Number(value);
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

function usageTokens(usage: unknown): UsageTokens {
  const record = usage && typeof usage === "object" ? (usage as Record<string, unknown>) : null;

  return {
    prompt_tokens: nullableInt(record?.prompt_tokens),
    completion_tokens: nullableInt(record?.completion_tokens),
    total_tokens: nullableInt(record?.total_tokens),
  };
}

function extractCloudflareChunk(payload: unknown): { text: string; usage: unknown | null } {
  if (!payload || typeof payload !== "object") {
    return { text: "", usage: null };
  }

  const record = payload as Record<string, unknown>;
  const result =
    record.result && typeof record.result === "object"
      ? (record.result as Record<string, unknown>)
      : null;
  const usage = record.usage ?? result?.usage ?? null;

  if (typeof record.response === "string") {
    return { text: record.response, usage };
  }

  if (typeof result?.response === "string") {
    return { text: result.response, usage };
  }

  const choices = record.choices;
  if (Array.isArray(choices) && choices[0] && typeof choices[0] === "object") {
    const choice = choices[0] as Record<string, unknown>;
    const delta =
      choice.delta && typeof choice.delta === "object"
        ? (choice.delta as Record<string, unknown>)
        : null;

    if (typeof delta?.content === "string") {
      return { text: delta.content, usage };
    }

    if (typeof choice.text === "string") {
      return { text: choice.text, usage };
    }
  }

  return { text: "", usage };
}

function consumeSsePayloads(buffer: string): { rest: string; payloads: string[] } {
  const normalized = buffer.replace(/\r\n/g, "\n");
  const lastNewline = normalized.lastIndexOf("\n");
  if (lastNewline === -1) {
    return { rest: buffer, payloads: [] };
  }

  const complete = normalized.slice(0, lastNewline);
  const rest = normalized.slice(lastNewline + 1);
  const payloads: string[] = [];

  for (const line of complete.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed.startsWith("data:")) {
      continue;
    }

    const payload = trimmed.slice("data:".length).trim();
    if (!payload || payload === "[DONE]") {
      continue;
    }

    payloads.push(payload);
  }

  return { rest, payloads };
}

async function getLatestRateMap(
  supabase: SupabaseClient,
  currencyPairs: Array<{ from: string; to: string }>,
) {
  const rateMap = new Map<string, number>();
  const remotePairs: Array<{ from: string; to: string }> = [];

  for (const pair of currencyPairs) {
    const key = `${pair.from}->${pair.to}`;
    if (pair.from === pair.to) {
      rateMap.set(key, 1);
      continue;
    }

    remotePairs.push(pair);
  }

  if (remotePairs.length === 0) {
    return rateMap;
  }

  const fromCurrencies = Array.from(new Set(remotePairs.map((pair) => pair.from)));
  const toCurrencies = Array.from(new Set(remotePairs.map((pair) => pair.to)));

  const { data, error } = await supabase
    .from("exchange_rates")
    .select("from_currency, to_currency, rate, created_at")
    .eq("is_active", true)
    .in("from_currency", fromCurrencies)
    .in("to_currency", toCurrencies)
    .order("created_at", { ascending: false });

  if (error || !data) {
    return rateMap;
  }

  for (const row of data) {
    const key = `${row.from_currency}->${row.to_currency}`;
    if (rateMap.has(key) || !row.rate) {
      continue;
    }

    rateMap.set(key, safeNumber(row.rate));
  }

  return rateMap;
}

async function loadRecentHistory(supabase: SupabaseClient, userId: string) {
  const { data, error } = await supabase
    .from("ai_chat_messages")
    .select("role, content")
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(HISTORY_LIMIT);

  if (error || !data) {
    return [] as Array<{ role: ChatRole; content: string }>;
  }

  return data
    .slice()
    .reverse()
    .filter((row) => row.role === "user" || row.role === "assistant")
    .map((row) => ({
      role: row.role as ChatRole,
      content: String(row.content ?? ""),
    }))
    .filter((row) => row.content.length > 0);
}

async function persistChatTurn(params: {
  supabase: SupabaseClient;
  userId: string;
  userMessage: string;
  assistantReply: string;
  model: string;
  usage: UsageTokens;
}): Promise<{ userMessageId: number; assistantMessageId: number }> {
  const { data, error } = await params.supabase
    .from("ai_chat_messages")
    .insert([
      {
        user_id: params.userId,
        role: "user",
        content: params.userMessage,
      },
      {
        user_id: params.userId,
        role: "assistant",
        content: params.assistantReply,
        model: params.model,
        prompt_tokens: params.usage.prompt_tokens,
        completion_tokens: params.usage.completion_tokens,
        total_tokens: params.usage.total_tokens,
      },
    ])
    .select("id, role");

  if (error) {
    throw new Error(`Failed to persist ai chat turn: ${error.message}`);
  }

  const rows = data ?? [];
  const userRow = rows.find((row) => row.role === "user");
  const assistantRow = rows.find((row) => row.role === "assistant");
  const userMessageId = Number(userRow?.id);
  const assistantMessageId = Number(assistantRow?.id);

  if (!Number.isFinite(userMessageId) || !Number.isFinite(assistantMessageId)) {
    throw new Error("Failed to persist ai chat turn: missing message ids");
  }

  return {
    userMessageId,
    assistantMessageId,
  };
}

function scheduleBackgroundWork(task: Promise<unknown>) {
  const wrapped = task.catch((error) => {
    console.error("Background ai chat work failed", error);
  });

  EdgeRuntime.waitUntil(wrapped);
}

async function loadFinanceContext(
  supabase: SupabaseClient,
  userId: string,
): Promise<FinanceContext> {
  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();
  const nextMonthStart = new Date(now.getFullYear(), now.getMonth() + 1, 1).toISOString();

  const [profileRes, walletsRes, transactionsRes, history] = await Promise.all([
    supabase
      .from("profiles")
      .select("full_name, base_currency, timezone")
      .eq("id", userId)
      .single(),
    supabase
      .from("wallets")
      .select("id, name, amount, currency_code, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: true }),
    supabase
      .from("transactions")
      .select(`
          id,
          note,
          amount,
          type,
          currency_code,
          transaction_date,
          created_at,
          wallet_id,
          category_id,
          wallets (
            id,
            name,
            currency_code
          ),
          categories (
            id,
            name,
            type,
            parent_id
          )
        `)
      .eq("user_id", userId)
      .gte("transaction_date", monthStart)
      .lt("transaction_date", nextMonthStart)
      .order("transaction_date", { ascending: false })
      .limit(TX_QUERY_LIMIT),
    loadRecentHistory(supabase, userId),
  ]);

  if (profileRes.error) {
    throw new Error(`Failed to load profile: ${profileRes.error.message}`);
  }

  if (walletsRes.error) {
    throw new Error(`Failed to load wallets: ${walletsRes.error.message}`);
  }

  if (transactionsRes.error) {
    throw new Error(`Failed to load transactions: ${transactionsRes.error.message}`);
  }

  const profile = profileRes.data;
  const wallets = walletsRes.data ?? [];
  const transactions = transactionsRes.data ?? [];

  const baseCurrency =
    profile?.base_currency?.toString().trim() ||
    wallets[0]?.currency_code?.toString().trim() ||
    "VND";

  const currencyPairsNeeded = new Map<string, { from: string; to: string }>();
  for (const tx of transactions) {
    const from = String(tx.currency_code ?? "").trim();
    const to = baseCurrency;
    if (from && to && from !== to) {
      currencyPairsNeeded.set(`${from}->${to}`, { from, to });
    }
  }

  const rateMap = await getLatestRateMap(supabase, Array.from(currencyPairsNeeded.values()));

  let totalExpenseBase = 0;
  let totalIncomeBase = 0;

  const expenseByCategory = new Map<string, number>();
  const txLines: string[] = [];

  for (const tx of transactions.slice(0, TX_LINE_LIMIT)) {
    const amount = safeNumber(tx.amount);
    const txCurrency = String(tx.currency_code ?? baseCurrency).trim();
    const key = `${txCurrency}->${baseCurrency}`;
    const rate = txCurrency === baseCurrency ? 1 : (rateMap.get(key) ?? null);
    const converted = rate ? amount * rate : null;

    const categoryName = (tx.categories as { name?: string } | null)?.name ?? "Unknown category";
    const walletName = (tx.wallets as { name?: string } | null)?.name ?? "Unknown wallet";

    txLines.push(
      `- ${tx.type} | ${formatMoney(amount, txCurrency)}${
        converted !== null && txCurrency !== baseCurrency
          ? ` (~${formatMoney(converted, baseCurrency)})`
          : ""
      } | ${categoryName} | ${walletName}${tx.note ? ` | ${tx.note}` : ""}`,
    );
  }

  for (const tx of transactions) {
    const amount = safeNumber(tx.amount);
    const txCurrency = String(tx.currency_code ?? baseCurrency).trim();
    const key = `${txCurrency}->${baseCurrency}`;
    const rate = txCurrency === baseCurrency ? 1 : (rateMap.get(key) ?? null);
    if (!rate) continue;

    const converted = amount * rate;
    const txType = String(tx.type ?? "").toLowerCase();
    const categoryName = (tx.categories as { name?: string } | null)?.name ?? "Unknown category";

    if (txType === "expense") {
      totalExpenseBase += converted;
      expenseByCategory.set(categoryName, (expenseByCategory.get(categoryName) ?? 0) + converted);
    } else if (txType === "income") {
      totalIncomeBase += converted;
    }
  }

  const topCategories = Array.from(expenseByCategory.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, TOP_CATEGORY_LIMIT);

  const walletLines = wallets.map((wallet) =>
    `- ${wallet.name ?? "Unnamed wallet"}: ${formatMoney(
      safeNumber(wallet.amount),
      String(wallet.currency_code ?? baseCurrency),
    )}`
  );

  const missingRateCurrencies = Array.from(
    new Set(
      transactions
        .filter((tx) => {
          const txCurrency = String(tx.currency_code ?? baseCurrency).trim();
          const key = `${txCurrency}->${baseCurrency}`;
          return txCurrency !== baseCurrency && !rateMap.get(key);
        })
        .map((tx) => String(tx.currency_code ?? "").trim())
        .filter(Boolean),
    ),
  );

  const context = `
User profile:
- Name: ${profile?.full_name ?? "Unknown"}
- Base currency: ${baseCurrency}
- Timezone: ${profile?.timezone ?? "Unknown"}

Current month summary:
- Total income: ${formatMoney(totalIncomeBase, baseCurrency)}
- Total expense: ${formatMoney(totalExpenseBase, baseCurrency)}
- Net: ${formatMoney(totalIncomeBase - totalExpenseBase, baseCurrency)}

Wallets:
${walletLines.length ? walletLines.join("\n") : "- No wallets"}

Top expense categories (converted to ${baseCurrency}):
${
    topCategories.length
      ? topCategories
        .map(([name, value]) => `- ${name}: ${formatMoney(value, baseCurrency)}`)
        .join("\n")
      : "- No expense data"
  }

Recent transactions:
${txLines.length ? txLines.join("\n") : "- No recent transactions"}

${
    missingRateCurrencies.length
      ? `Missing exchange rates to ${baseCurrency} for: ${missingRateCurrencies.join(", ")}`
      : "All required exchange rates were available for current summary."
  }
    `.trim();

  return {
    context,
    history,
    debug: {
      base_currency: baseCurrency,
      wallet_count: wallets.length,
      transaction_count: transactions.length,
      missing_rate_currencies: missingRateCurrencies,
    },
  };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "Missing Authorization header" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SB_PUBLISHABLE_KEY");

    if (!supabaseUrl || !supabaseAnonKey) {
      return json({ error: "Missing Supabase environment config" }, 500);
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: {
          Authorization: authHeader,
        },
      },
    });

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return json(
        { error: "Unauthorized", details: userError?.message ?? null },
        401,
      );
    }

    const body = await req.json().catch(() => null);
    const message = body?.message?.toString()?.trim();

    if (!message) {
      return json({ error: "Missing message" }, 400);
    }

    if (message.length > MAX_MESSAGE_LENGTH) {
      return json({ error: "Message is too long" }, 400);
    }

    const accountId = Deno.env.get("CLOUDFLARE_ACCOUNT_ID");
    const aiToken = Deno.env.get("CLOUDFLARE_AI_TOKEN");
    const model = Deno.env.get("CLOUDFLARE_AI_MODEL") ?? "@cf/meta/llama-3.1-8b-instruct";

    if (!accountId || !aiToken) {
      return json({ error: "Missing Cloudflare AI secrets" }, 500);
    }

    const stream = new ReadableStream<Uint8Array>({
      async start(controller) {
        let closed = false;
        let reader: ReadableStreamDefaultReader<Uint8Array> | undefined;
        let reply = "";
        let usage: unknown | null = null;
        let persistScheduled = false;
        let heartbeatTimer: ReturnType<typeof setTimeout> | undefined;

        const stopHeartbeat = () => {
          if (heartbeatTimer === undefined) {
            return;
          }
          clearTimeout(heartbeatTimer);
          heartbeatTimer = undefined;
        };

        const close = () => {
          stopHeartbeat();
          if (closed) {
            return;
          }
          closed = true;
          try {
            controller.close();
          } catch {
            // already closed
          }
        };

        const armHeartbeat = () => {
          stopHeartbeat();
          heartbeatTimer = setTimeout(() => {
            heartbeatTimer = undefined;
            if (closed) {
              return;
            }
            try {
              controller.enqueue(sseComment(HEARTBEAT_COMMENT));
              armHeartbeat();
            } catch {
              close();
            }
          }, HEARTBEAT_INTERVAL_MS);
        };

        const send = (data: unknown) => {
          if (closed) {
            return;
          }
          try {
            controller.enqueue(sseFrame(data));
            armHeartbeat();
          } catch {
            close();
          }
        };

        const cancelReader = () => {
          void reader?.cancel().catch(() => {
            // already cancelled
          });
        };

        const fail = (error: string, details: unknown = null) => {
          cancelReader();
          send({ type: "error", error, details });
          close();
        };

        const persistTurn = (assistantReply: string) => {
          if (persistScheduled || !assistantReply) {
            return Promise.resolve(null);
          }

          persistScheduled = true;
          const task = persistChatTurn({
            supabase,
            userId: user.id,
            userMessage: message,
            assistantReply,
            model,
            usage: usageTokens(usage),
          }).catch((error) => {
            console.error("Background ai chat work failed", error);
            return null;
          });

          scheduleBackgroundWork(task);
          return task;
        };

        const persistPartialInBackground = () => {
          const partialReply = reply.trim();
          if (!partialReply) {
            return;
          }
          void persistTurn(partialReply);
        };

        const onAbort = () => {
          cancelReader();
        };

        if (req.signal.aborted) {
          close();
          return;
        }

        req.signal.addEventListener("abort", onAbort, { once: true });

        try {
          send({ type: "start" });
          send({ type: "status", status: "loading_context" });

          const finance = await loadFinanceContext(supabase, user.id);

          if (req.signal.aborted) {
            close();
            return;
          }

          const aiRes = await fetch(
            `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/${model}`,
            {
              method: "POST",
              headers: {
                Authorization: `Bearer ${aiToken}`,
                "Content-Type": "application/json",
                Accept: "text/event-stream",
              },
              body: JSON.stringify({
                stream: true,
                messages: [
                  { role: "system", content: SYSTEM_PROMPT },
                  { role: "system", content: `Walleto data context:\n${finance.context}` },
                  ...finance.history.map((item) => ({
                    role: item.role,
                    content: item.content,
                  })),
                  { role: "user", content: message },
                ],
              }),
              signal: req.signal,
            },
          );

          if (!aiRes.ok) {
            const details = await aiRes.json().catch(() => null);
            fail("Cloudflare AI request failed", details);
            return;
          }

          if (!aiRes.body) {
            fail("Cloudflare AI returned an empty stream");
            return;
          }

          reader = aiRes.body.getReader();
          if (req.signal.aborted) {
            persistPartialInBackground();
            cancelReader();
            close();
            return;
          }

          const decoder = new TextDecoder();
          let buffer = "";

          while (true) {
            const { done, value } = await reader.read();
            if (done) {
              break;
            }

            buffer += decoder.decode(value, { stream: true });
            const consumed = consumeSsePayloads(buffer);
            buffer = consumed.rest;

            for (const payload of consumed.payloads) {
              let parsed: unknown;
              try {
                parsed = JSON.parse(payload);
              } catch {
                continue;
              }

              if (
                parsed &&
                typeof parsed === "object" &&
                (parsed as { success?: unknown }).success === false
              ) {
                fail("Cloudflare AI request failed", parsed);
                return;
              }

              const chunk = extractCloudflareChunk(parsed);
              if (chunk.usage) {
                usage = chunk.usage;
              }
              if (chunk.text) {
                reply += chunk.text;
                send({ type: "delta", content: chunk.text });
              }
            }
          }

          if (!reply && buffer.trim()) {
            try {
              const parsed = JSON.parse(buffer.trim());
              if (
                parsed &&
                typeof parsed === "object" &&
                (parsed as { success?: unknown }).success === false
              ) {
                fail("Cloudflare AI request failed", parsed);
                return;
              }

              const chunk = extractCloudflareChunk(parsed);
              if (chunk.usage) {
                usage = chunk.usage;
              }
              if (chunk.text) {
                reply = chunk.text;
                send({ type: "delta", content: chunk.text });
              }
            } catch {
              // leftover was a partial SSE frame, not a JSON body
            }
          }

          if (req.signal.aborted) {
            persistPartialInBackground();
            close();
            return;
          }

          const finalReply = reply.trim();
          if (!finalReply) {
            fail("Cloudflare AI returned an empty reply");
            return;
          }

          send({
            type: "done",
            usage,
            model,
            debug_context: finance.debug,
          });

          const ids = await persistTurn(finalReply);
          if (ids && !closed && !req.signal.aborted) {
            send({
              type: "persisted",
              user_message_id: ids.userMessageId,
              assistant_message_id: ids.assistantMessageId,
            });
          }
          close();
        } catch (error) {
          if (error instanceof Error && error.name === "AbortError") {
            persistPartialInBackground();
            cancelReader();
            close();
            return;
          }

          fail(
            "Unexpected server error",
            error instanceof Error ? error.message : String(error),
          );
        }
      },
    });

    return new Response(stream, { headers: sseHeaders });
  } catch (error) {
    return json(
      {
        error: "Unexpected server error",
        details: error instanceof Error ? error.message : String(error),
      },
      500,
    );
  }
});
