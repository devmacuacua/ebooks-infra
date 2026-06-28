-- Uma base de dados por serviço (isolamento total)
CREATE DATABASE auth_db;         -- ebooks-auth-service
CREATE DATABASE catalog_db;      -- ebooks-catalog-service
CREATE DATABASE commerce_db;     -- ebooks-commerce-service (cart + orders + payments + subscriptions)
CREATE DATABASE reading_db;      -- ebooks-reading-service (DRM + sessões de leitura)
CREATE DATABASE notification_db; -- ebooks-notification-service
CREATE DATABASE social_db;       -- ebooks-social-service
CREATE DATABASE media_db;        -- ebooks-media-service
CREATE DATABASE partner_db;     -- ebooks-partner-service (API keys + widgets + webhooks + revenue)
CREATE DATABASE delivery_db;    -- ebooks-delivery-service (entregas físicas + rastreio)
CREATE DATABASE analytics_db;   -- ebooks-analytics-service (read model + snapshots)
