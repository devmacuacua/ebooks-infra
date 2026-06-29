-- =============================================================================
-- Seed: partner_db — parceiro de teste
-- Depende de seed.sql (usa o userId do utilizador editora@ndzidzi.co.mz)
-- =============================================================================
\connect partner_db

INSERT INTO "Partner" (id, "userId", name, email, "websiteUrl", description, "revenueSharePct", status, "createdAt", "updatedAt")
VALUES (
  'pt000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000005',
  'Editora Ndzidzi',
  'editora@ndzidzi.co.mz',
  'https://www.ndzidzi.co.mz',
  'Editora moçambicana especializada em literatura local e obras académicas.',
  80,
  'ACTIVE',
  NOW(), NOW()
) ON CONFLICT ("userId") DO NOTHING;
