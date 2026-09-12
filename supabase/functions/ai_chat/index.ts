import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const HISTORY_LIMIT = 10;
const TX_LINE_LIMIT = 8;
const TX_QUERY_LIMIT = 100;
const TOP_CATEGORY_LIMIT = 3;
const MAX_MESSAGE_LENGTH = 2000;

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
`.trim();

type ChatRole = "user" | "assistant";

type UsageTokens = {
  prompt_tokens: number | null;
  completion_tokens: number | null;
  total_tokens: number | null;
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
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

async function getLatestRateMap(
  supabase: ReturnType<typeof createClient>,
  currencyPairs: Array<{ from: string; to: string }>,
) {
  const rateMap = new Map<string, number>();

  for (const pair of currencyPairs) {
    const key = `${pair.from}->${pair.to}`;
    if (pair.from === pair.to) {
      rateMap.set(key, 1);
      continue;
    }

    const { data, error } = await supabase
      .from("exchange_rates")
      .select("from_currency, to_currency, rate, created_at")
      .eq("from_currency", pair.from)
      .eq("to_currency", pair.to)
      .eq("is_active", true)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (!error && data?.rate) {
      rateMap.set(key, safeNumber(data.rate));
    }
  }

  return rateMap;
}

async function loadRecentHistory(
  supabase: ReturnType<typeof createClient>,
  userId: string,
) {
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
  supabase: ReturnType<typeof createClient>;
  userId: string;
  userMessage: string;
  assistantReply: string;
  model: string;
  usage: UsageTokens;
}) {
  const { error: userInsertError } = await params.supabase.from("ai_chat_messages").insert({
    user_id: params.userId,
    role: "user",
    content: params.userMessage,
  });

  if (userInsertError) {
    console.error("Failed to persist user ai chat message", userInsertError);
    return;
  }

  const { error: assistantInsertError } = await params.supabase.from("ai_chat_messages").insert({
    user_id: params.userId,
    role: "assistant",
    content: params.assistantReply,
    model: params.model,
    prompt_tokens: params.usage.prompt_tokens,
    completion_tokens: params.usage.completion_tokens,
    total_tokens: params.usage.total_tokens,
  });

  if (assistantInsertError) {
    console.error("Failed to persist assistant ai chat message", assistantInsertError);
  }
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
    const supabaseAnonKey =
      Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SB_PUBLISHABLE_KEY");

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

    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();
    const nextMonthStart = new Date(
      now.getFullYear(),
      now.getMonth() + 1,
      1,
    ).toISOString();

    const [
      profileRes,
      walletsRes,
      transactionsRes,
      history,
    ] = await Promise.all([
      supabase
        .from("profiles")
        .select("full_name, base_currency, timezone")
        .eq("id", user.id)
        .single(),
      supabase
        .from("wallets")
        .select("id, name, amount, currency_code, created_at")
        .eq("user_id", user.id)
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
        .eq("user_id", user.id)
        .gte("transaction_date", monthStart)
        .lt("transaction_date", nextMonthStart)
        .order("transaction_date", { ascending: false })
        .limit(TX_QUERY_LIMIT),
      loadRecentHistory(supabase, user.id),
    ]);

    if (profileRes.error) {
      return json(
        { error: "Failed to load profile", details: profileRes.error.message },
        500,
      );
    }

    if (walletsRes.error) {
      return json(
        { error: "Failed to load wallets", details: walletsRes.error.message },
        500,
      );
    }

    if (transactionsRes.error) {
      return json(
        {
          error: "Failed to load transactions",
          details: transactionsRes.error.message,
        },
        500,
      );
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

    const rateMap = await getLatestRateMap(
      supabase,
      Array.from(currencyPairsNeeded.values()),
    );

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

      const categoryName =
        (tx.categories as { name?: string } | null)?.name ?? "Unknown category";
      const walletName =
        (tx.wallets as { name?: string } | null)?.name ?? "Unknown wallet";

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
      const categoryName =
        (tx.categories as { name?: string } | null)?.name ?? "Unknown category";

      if (txType === "expense") {
        totalExpenseBase += converted;
        expenseByCategory.set(
          categoryName,
          (expenseByCategory.get(categoryName) ?? 0) + converted,
        );
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

    const accountId = Deno.env.get("CLOUDFLARE_ACCOUNT_ID");
    const aiToken = Deno.env.get("CLOUDFLARE_AI_TOKEN");
    const model =
      Deno.env.get("CLOUDFLARE_AI_MODEL") ?? "@cf/meta/llama-3.1-8b-instruct";

    if (!accountId || !aiToken) {
      return json({ error: "Missing Cloudflare AI secrets" }, 500);
    }

    const aiRes = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/${model}`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${aiToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            { role: "system", content: `Walleto data context:\n${context}` },
            ...history.map((item) => ({ role: item.role, content: item.content })),
            { role: "user", content: message },
          ],
        }),
      },
    );

    const aiData = await aiRes.json();

    if (!aiRes.ok || !aiData?.success) {
      return json(
        {
          error: "Cloudflare AI request failed",
          details: aiData,
        },
        500,
      );
    }

    const reply = String(aiData?.result?.response ?? "").trim();
    const usage = usageTokens(aiData?.result?.usage);

    if (!reply) {
      return json({ error: "Cloudflare AI returned an empty reply" }, 500);
    }

    await persistChatTurn({
      supabase,
      userId: user.id,
      userMessage: message,
      assistantReply: reply,
      model,
      usage,
    });

    return json({
      reply,
      usage: aiData?.result?.usage ?? null,
      model,
      debug_context: {
        base_currency: baseCurrency,
        wallet_count: wallets.length,
        transaction_count: transactions.length,
        missing_rate_currencies: missingRateCurrencies,
      },
    });
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
