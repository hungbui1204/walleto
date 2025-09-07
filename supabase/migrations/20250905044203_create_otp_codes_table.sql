create table otp_codes (
    id bigserial primary key,
    email text not null,
    code text not null,
    expires_at timestamp not null,
    used boolean default false
);