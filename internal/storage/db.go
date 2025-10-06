// internal/storage/db.go
package storage

import (
	"database/sql"
	"fmt"
	"time"
)

type PostgresDB struct {
	db *sql.DB
}

func NewPostgresDB(dsn string) (*PostgresDB, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Configure connection pool
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)
	db.SetConnMaxLifetime(5 * time.Minute)
	db.SetConnMaxIdleTime(10 * time.Minute)

	// Test connection
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return &PostgresDB{db: db}, nil
}

func (p *PostgresDB) Close() error {
	return p.db.Close()
}

func (p *PostgresDB) InitSchema() error {
	schema := `
	CREATE TABLE IF NOT EXISTS fields (
		id VARCHAR(255) PRIMARY KEY,
		name VARCHAR(255) NOT NULL,
		location JSONB,
		crop_type VARCHAR(100),
		area_hectares DECIMAL(10,2),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS devices (
		id VARCHAR(255) PRIMARY KEY,
		field_id VARCHAR(255) REFERENCES fields(id),
		device_type VARCHAR(100),
		status VARCHAR(50),
		last_seen TIMESTAMP,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);

	CREATE TABLE IF NOT EXISTS alerts (
		id SERIAL PRIMARY KEY,
		field_id VARCHAR(255) REFERENCES fields(id),
		alert_type VARCHAR(100),
		severity VARCHAR(50),
		message TEXT,
		resolved BOOLEAN DEFAULT FALSE,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		resolved_at TIMESTAMP
	);

	CREATE INDEX IF NOT EXISTS idx_fields_crop_type ON fields(crop_type);
	CREATE INDEX IF NOT EXISTS idx_devices_field_id ON devices(field_id);
	CREATE INDEX IF NOT EXISTS idx_alerts_field_id ON alerts(field_id);
	CREATE INDEX IF NOT EXISTS idx_alerts_resolved ON alerts(resolved);
	`

	_, err := p.db.Exec(schema)
	return err
}
