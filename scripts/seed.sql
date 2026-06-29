-- =============================================================================
-- EBooksStore — Seed de dados fictícios para desenvolvimento e testes
-- Idempotente: seguro para executar várias vezes (ON CONFLICT DO NOTHING)
-- Senhas: Admin@1234 (admin) · Test@1234 (clientes/partner)
-- =============================================================================

-- ─── auth_db ─────────────────────────────────────────────────────────────────
\connect auth_db

-- Garantir extensão
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO users (id, email, name, password_hash, role, email_verified, is_active, created_at, updated_at)
VALUES
  -- Admin
  ('00000000-0000-0000-0000-000000000001',
   'admin@ebooks.co.mz', 'Administrador',
   crypt('Admin@1234', gen_salt('bf', 10)),
   'ADMIN', NOW(), true, NOW(), NOW()),

  -- Clientes
  ('00000000-0000-0000-0000-000000000002',
   'francisco@ebooks.co.mz', 'Francisco Macuacua',
   crypt('Test@1234', gen_salt('bf', 10)),
   'CUSTOMER', NOW(), true, NOW(), NOW()),

  ('00000000-0000-0000-0000-000000000003',
   'maria@ebooks.co.mz', 'Maria da Graça',
   crypt('Test@1234', gen_salt('bf', 10)),
   'CUSTOMER', NOW(), true, NOW(), NOW()),

  ('00000000-0000-0000-0000-000000000004',
   'joao@ebooks.co.mz', 'João Nhantumbo',
   crypt('Test@1234', gen_salt('bf', 10)),
   'CUSTOMER', NOW(), true, NOW(), NOW()),

  -- Parceiro
  ('00000000-0000-0000-0000-000000000005',
   'editora@ndzidzi.co.mz', 'Editora Ndzidzi',
   crypt('Test@1234', gen_salt('bf', 10)),
   'CUSTOMER', NOW(), true, NOW(), NOW())
ON CONFLICT (email) DO NOTHING;


-- ─── catalog_db ──────────────────────────────────────────────────────────────
\connect catalog_db

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Autores
INSERT INTO authors (id, name, bio, created_at)
VALUES
  ('a0000000-0000-0000-0000-000000000001', 'Mia Couto',
   'Escritor moçambicano, um dos mais reconhecidos da literatura africana de língua portuguesa. Vencedor do Prémio Camões 2013.',
   NOW()),
  ('a0000000-0000-0000-0000-000000000002', 'Paulina Chiziane',
   'Primeira mulher moçambicana a publicar um romance. Autora de "Niketche: Uma história de poligamia".',
   NOW()),
  ('a0000000-0000-0000-0000-000000000003', 'José Craveirinha',
   'Considerado o maior poeta moçambicano. Vencedor do Prémio Camões 1991.',
   NOW()),
  ('a0000000-0000-0000-0000-000000000004', 'Ungulani Ba Ka Khosa',
   'Escritor e jornalista moçambicano, autor de "Ualalapi", clássico da literatura moçambicana.',
   NOW()),
  ('a0000000-0000-0000-0000-000000000005', 'Lília Momplé',
   'Escritora moçambicana, autora de "Neighbours" e "Os Olhos da Cobra Verde".',
   NOW())
ON CONFLICT (id) DO NOTHING;

-- Categorias
INSERT INTO categories (id, name, slug, icon)
VALUES
  ('c0000000-0000-0000-0000-000000000001', 'Literatura Moçambicana', 'literatura-mocambicana', 'BookOpen'),
  ('c0000000-0000-0000-0000-000000000002', 'Romance',                'romance',                'Heart'),
  ('c0000000-0000-0000-0000-000000000003', 'Poesia',                 'poesia',                 'Feather'),
  ('c0000000-0000-0000-0000-000000000004', 'Ficção Científica',      'ficcao-cientifica',      'Zap'),
  ('c0000000-0000-0000-0000-000000000005', 'Desenvolvimento Pessoal','desenvolvimento-pessoal','TrendingUp'),
  ('c0000000-0000-0000-0000-000000000006', 'Negócios',               'negocios',               'Briefcase')
ON CONFLICT (id) DO NOTHING;

-- Tags
INSERT INTO tags (id, name)
VALUES
  ('t0000000-0000-0000-0000-000000000001', 'clássico'),
  ('t0000000-0000-0000-0000-000000000002', 'contemporâneo'),
  ('t0000000-0000-0000-0000-000000000003', 'bestseller')
ON CONFLICT (id) DO NOTHING;

-- Livros (status + novos campos V2/V3)
INSERT INTO books (
  id, title, slug, description, type, price, language,
  pages, publisher, isbn, is_active, is_featured, subscription_only,
  status, average_rating, review_count,
  cover_image, file_key, format, stock_quantity,
  published_at, created_at, updated_at
) VALUES
  -- 1. Ebook premium + físico (featured)
  ('b0000000-0000-0000-0000-000000000001',
   'Terra Sonâmbula', 'terra-sonambula',
   'Uma viagem através de Moçambique em guerra civil, narrada por um velho e um rapaz fugitivos. O romance mais celebrado de Mia Couto.',
   'BOTH', 350.00, 'pt',
   216, 'Editorial Caminho', '978-972-21-0801-9',
   true, true, false, 'PUBLISHED',
   4.8, 124,
   NULL, 'ebooks/terra-sonambula.pdf', 'PDF', 15,
   '2004-01-01', NOW(), NOW()),

  -- 2. Ebook only, subscrição
  ('b0000000-0000-0000-0000-000000000002',
   'Niketche: Uma História de Poligamia', 'niketche-uma-historia-de-poligamia',
   'Romance sobre a condição feminina em Moçambique, explorando tradições, amor e identidade.',
   'EBOOK', 0.00, 'pt',
   278, 'Editorial Ndjira', '978-989-526-148-0',
   true, true, true, 'PUBLISHED',
   4.7, 89,
   NULL, 'ebooks/niketche.pdf', 'PDF', 0,
   '2002-01-01', NOW(), NOW()),

  -- 3. Físico apenas
  ('b0000000-0000-0000-0000-000000000003',
   'Karingana wa Karingana', 'karingana-wa-karingana',
   'Colectânea de poemas de José Craveirinha, considerado o pai da poesia moçambicana moderna.',
   'PHYSICAL', 280.00, 'pt',
   180, 'AEMO', NULL,
   true, false, false, 'PUBLISHED',
   4.9, 56,
   NULL, NULL, NULL, 30,
   '1974-01-01', NOW(), NOW()),

  -- 4. Ebook (subscrição)
  ('b0000000-0000-0000-0000-000000000004',
   'Ualalapi', 'ualalapi',
   'Romance histórico sobre o último rei de Gaza, Ngungunyane, e a resistência à colonização portuguesa.',
   'EBOOK', 0.00, 'pt',
   134, 'AEMO', '978-989-632-012-3',
   true, false, true, 'PUBLISHED',
   4.6, 43,
   NULL, 'ebooks/ualalapi.pdf', 'PDF', 0,
   '1987-01-01', NOW(), NOW()),

  -- 5. Físico + Ebook (desenvolvimento pessoal)
  ('b0000000-0000-0000-0000-000000000005',
   'Liderança em África: Princípios Ubuntu', 'lideranca-africa-ubuntu',
   'Guia prático de liderança inspirado na filosofia Ubuntu e nas tradições de gestão africanas.',
   'BOTH', 450.00, 'pt',
   256, 'Editora Ndzidzi', NULL,
   true, false, false, 'PUBLISHED',
   4.3, 28,
   NULL, 'ebooks/lideranca-africa.pdf', 'PDF', 20,
   '2022-06-01', NOW(), NOW()),

  -- 6. Ebook (negócios)
  ('b0000000-0000-0000-0000-000000000006',
   'Empreender em Moçambique: Guia Prático', 'empreender-mocambique-guia-pratico',
   'Passos práticos para abrir e gerir um negócio em Moçambique: licenças, fiscalidade, financiamento e marketing.',
   'EBOOK', 299.00, 'pt',
   312, 'Editora Horizonte', NULL,
   true, true, false, 'PUBLISHED',
   4.4, 67,
   NULL, 'ebooks/empreender-mocambique.pdf', 'PDF', 0,
   '2023-03-15', NOW(), NOW()),

  -- 7. Físico (romance)
  ('b0000000-0000-0000-0000-000000000007',
   'Neighbours', 'neighbours',
   'Romance sobre as relações entre vizinhos de diferentes origens étnicas na Lourenço Marques colonial.',
   'PHYSICAL', 220.00, 'pt',
   192, 'AEMO', NULL,
   true, false, false, 'PUBLISHED',
   4.5, 34,
   NULL, NULL, NULL, 10,
   '1995-01-01', NOW(), NOW()),

  -- 8. PENDING_REVIEW (submetido por parceiro)
  ('b0000000-0000-0000-0000-000000000008',
   'Maputo ao Amanhecer', 'maputo-ao-amanhecer',
   'Crónicas poéticas sobre a capital moçambicana, entre o moderno e o tradicional.',
   'EBOOK', 150.00, 'pt',
   96, 'Editora Ndzidzi', NULL,
   false, false, false, 'PENDING_REVIEW',
   0.0, 0,
   NULL, 'submissions/maputo-amanhecer.pdf', 'PDF', 0,
   NULL, NOW(), NOW()),

  -- 9. REJECTED (com parecer)
  ('b0000000-0000-0000-0000-000000000009',
   'Rascunho Inacabado', 'rascunho-inacabado',
   'Rascunho inicial de ficção científica ambientado em Maputo 2150.',
   'EBOOK', 100.00, 'pt',
   45, NULL, NULL,
   false, false, false, 'REJECTED',
   0.0, 0,
   NULL, NULL, NULL, 0,
   NULL, NOW(), NOW()),

  -- 10. Ebook (ficção científica, featured)
  ('b0000000-0000-0000-0000-000000000010',
   'Nação Futura', 'nacao-futura',
   'Ficção científica que imagina Moçambique em 2150: uma nação tecnológica que preservou as suas raízes.',
   'EBOOK', 199.00, 'pt',
   340, 'Editora Horizonte', NULL,
   true, true, false, 'PUBLISHED',
   4.2, 19,
   NULL, 'ebooks/nacao-futura.pdf', 'PDF', 0,
   '2024-01-20', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Actualizar campos de submissão para os livros do parceiro
UPDATE books SET
  partner_id   = '00000000-0000-0000-0000-000000000005',
  partner_name = 'Editora Ndzidzi',
  submitted_at = NOW() - INTERVAL '2 days'
WHERE id IN (
  'b0000000-0000-0000-0000-000000000008',
  'b0000000-0000-0000-0000-000000000009'
);

UPDATE books SET
  rejection_reason = 'O conteúdo tem apenas 45 páginas, abaixo do mínimo exigido de 80 páginas. Por favor reveja e complete o manuscrito antes de resubmeter.'
WHERE id = 'b0000000-0000-0000-0000-000000000009';

-- Associações livro–autor
INSERT INTO book_authors (book_id, author_id) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002'),
  ('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000003'),
  ('b0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000004'),
  ('b0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000005'),
  ('b0000000-0000-0000-0000-000000000006', 'a0000000-0000-0000-0000-000000000005'),
  ('b0000000-0000-0000-0000-000000000007', 'a0000000-0000-0000-0000-000000000005'),
  ('b0000000-0000-0000-0000-000000000008', 'a0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000009', 'a0000000-0000-0000-0000-000000000002'),
  ('b0000000-0000-0000-0000-000000000010', 'a0000000-0000-0000-0000-000000000004')
ON CONFLICT DO NOTHING;

-- Associações livro–categoria
INSERT INTO book_categories (book_id, category_id) VALUES
  ('b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002'),
  ('b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002'),
  ('b0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000003'),
  ('b0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000005'),
  ('b0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000006'),
  ('b0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000006'),
  ('b0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000002'),
  ('b0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000001'),
  ('b0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000003'),
  ('b0000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000004'),
  ('b0000000-0000-0000-0000-000000000010', 'c0000000-0000-0000-0000-000000000004')
ON CONFLICT DO NOTHING;

-- Avaliações (para os livros publicados)
INSERT INTO reviews (id, book_id, user_id, user_name, rating, comment, created_at)
VALUES
  (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002', 'Francisco Macuacua',
   5, 'Um dos melhores livros que já li. A escrita de Mia Couto é simplesmente mágica.', NOW() - INTERVAL '10 days'),
  (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000003', 'Maria da Graça',
   5, 'Leitura obrigatória para quem quer entender Moçambique.', NOW() - INTERVAL '5 days'),
  (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000004', 'João Nhantumbo',
   4, 'Perspectiva poderosa sobre a vida da mulher moçambicana. Recomendo.', NOW() - INTERVAL '3 days'),
  (gen_random_uuid(), 'b0000000-0000-0000-0000-000000000006',
   '00000000-0000-0000-0000-000000000002', 'Francisco Macuacua',
   4, 'Muito prático e adaptado à realidade moçambicana. Ajudou-me bastante no meu negócio.', NOW() - INTERVAL '7 days')
ON CONFLICT DO NOTHING;


-- ─── commerce_db ─────────────────────────────────────────────────────────────
\connect commerce_db

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Planos de subscrição
INSERT INTO subscription_plans (id, name, description, price, currency, interval_days, is_active, created_at)
VALUES
  ('sp000000-0000-0000-0000-000000000001',
   'Mensal', 'Acesso ilimitado a todos os ebooks por 30 dias.',
   199.00, 'MZN', 30, true, NOW()),
  ('sp000000-0000-0000-0000-000000000002',
   'Anual', 'Acesso ilimitado a todos os ebooks por 365 dias. Poupança de 20%.',
   1499.00, 'MZN', 365, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Subscrição activa para Francisco
INSERT INTO subscriptions (id, user_id, plan_id, status, started_at, expires_at, created_at, updated_at)
VALUES
  ('sub00000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'sp000000-0000-0000-0000-000000000001',
   'ACTIVE',
   NOW() - INTERVAL '5 days',
   NOW() + INTERVAL '25 days',
   NOW() - INTERVAL '5 days',
   NOW())
ON CONFLICT (id) DO NOTHING;

-- Endereço de entrega (Francisco)
INSERT INTO addresses (id, user_id, name, street, number, district, city, province, country, is_default, created_at)
VALUES
  ('addr0000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000002',
   'Francisco Macuacua',
   'Av. Julius Nyerere', '1234',
   'Sommerschield', 'Maputo', 'Maputo',
   'Moçambique', true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Encomenda 1: entregue (livro físico — Terra Sonâmbula)
INSERT INTO orders (id, order_number, user_id, address_id, status, subtotal, delivery_fee, total, currency, created_at, updated_at)
VALUES
  ('ord00000-0000-0000-0000-000000000001',
   'EB-2025-00001',
   '00000000-0000-0000-0000-000000000002',
   'addr0000-0000-0000-0000-000000000001',
   'DELIVERED', 350.00, 150.00, 500.00, 'MZN',
   NOW() - INTERVAL '20 days', NOW() - INTERVAL '15 days')
ON CONFLICT (id) DO NOTHING;

INSERT INTO order_items (id, order_id, book_id, book_title, book_type, quantity, unit_price, total_price)
VALUES
  (gen_random_uuid(),
   'ord00000-0000-0000-0000-000000000001',
   'b0000000-0000-0000-0000-000000000001',
   'Terra Sonâmbula', 'BOTH', 1, 350.00, 350.00)
ON CONFLICT DO NOTHING;

-- Encomenda 2: em processamento (ebook)
INSERT INTO orders (id, order_number, user_id, status, subtotal, delivery_fee, total, currency, created_at, updated_at)
VALUES
  ('ord00000-0000-0000-0000-000000000002',
   'EB-2025-00002',
   '00000000-0000-0000-0000-000000000003',
   'PROCESSING', 299.00, 0.00, 299.00, 'MZN',
   NOW() - INTERVAL '1 day', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO order_items (id, order_id, book_id, book_title, book_type, quantity, unit_price, total_price)
VALUES
  (gen_random_uuid(),
   'ord00000-0000-0000-0000-000000000002',
   'b0000000-0000-0000-0000-000000000006',
   'Empreender em Moçambique: Guia Prático', 'EBOOK', 1, 299.00, 299.00)
ON CONFLICT DO NOTHING;
