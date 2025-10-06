// pkg/cache/redis.go
package cache

import (
	"context"
	"encoding/json"
	"time"

	"github.com/go-redis/redis/v8"
)

type RedisCache struct {
	client *redis.Client
}

func NewRedisCache(addr string) *RedisCache {
	client := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	return &RedisCache{
		client: client,
	}
}

func (r *RedisCache) SetKnowledgeResult(ctx context.Context, query string, result interface{}, ttl time.Duration) error {
	data, err := json.Marshal(result)
	if err != nil {
		return err
	}

	return r.client.Set(ctx, "knowledge:"+query, data, ttl).Err()
}

func (r *RedisCache) GetKnowledgeResult(ctx context.Context, query string, result interface{}) error {
	data, err := r.client.Get(ctx, "knowledge:"+query).Bytes()
	if err != nil {
		return err
	}

	return json.Unmarshal(data, result)
}

func (r *RedisCache) SetSensorData(ctx context.Context, deviceID string, data interface{}, ttl time.Duration) error {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	return r.client.Set(ctx, "sensor:"+deviceID, jsonData, ttl).Err()
}

func (r *RedisCache) GetSensorData(ctx context.Context, deviceID string, data interface{}) error {
	jsonData, err := r.client.Get(ctx, "sensor:"+deviceID).Bytes()
	if err != nil {
		return err
	}

	return json.Unmarshal(jsonData, data)
}

func (r *RedisCache) Close() error {
	return r.client.Close()
}
