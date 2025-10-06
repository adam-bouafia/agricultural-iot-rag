// pkg/rag/vector_store.go
package rag

import (
	"context"
	"fmt"

	pb "github.com/qdrant/go-client/qdrant"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type VectorStore struct {
	pointsClient      pb.PointsClient
	collectionsClient pb.CollectionsClient
	collection        string
}

func NewVectorStore(url string, collection string) (*VectorStore, error) {
	conn, err := grpc.Dial(url, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, fmt.Errorf("failed to connect to Qdrant: %w", err)
	}

	vs := &VectorStore{
		pointsClient:      pb.NewPointsClient(conn),
		collectionsClient: pb.NewCollectionsClient(conn),
		collection:        collection,
	}

	// Initialize collection if needed
	if err := vs.initCollection(context.Background()); err != nil {
		return nil, err
	}

	return vs, nil
}

func (vs *VectorStore) initCollection(ctx context.Context) error {
	// Check if collection exists
	response, err := vs.collectionsClient.List(ctx, &pb.ListCollectionsRequest{})
	if err != nil {
		return fmt.Errorf("failed to list collections: %w", err)
	}

	// Check if our collection exists
	exists := false
	for _, col := range response.Collections {
		if col.Name == vs.collection {
			exists = true
			break
		}
	}

	if !exists {
		// Create collection with 768 dimensions (default for many embedding models)
		_, err := vs.collectionsClient.Create(ctx, &pb.CreateCollection{
			CollectionName: vs.collection,
			VectorsConfig: &pb.VectorsConfig{
				Config: &pb.VectorsConfig_Params{
					Params: &pb.VectorParams{
						Size:     768,
						Distance: pb.Distance_Cosine,
					},
				},
			},
		})
		if err != nil {
			return fmt.Errorf("failed to create collection: %w", err)
		}
	}

	return nil
}

func (vs *VectorStore) AddDocument(ctx context.Context, id string, text string, embedding []float32, metadata map[string]interface{}) error {
	// Convert metadata to Qdrant payload format
	payload := make(map[string]*pb.Value)
	for key, val := range metadata {
		payload[key] = &pb.Value{
			Kind: &pb.Value_StringValue{
				StringValue: fmt.Sprintf("%v", val),
			},
		}
	}
	// Add the text content
	payload["content"] = &pb.Value{
		Kind: &pb.Value_StringValue{
			StringValue: text,
		},
	}

	// Use numeric ID instead of UUID to avoid parsing issues
	// Hash the string ID to get a numeric value
	var numericId uint64
	for i, c := range id {
		numericId = numericId*31 + uint64(c) + uint64(i)
	}

	points := []*pb.PointStruct{
		{
			Id: &pb.PointId{
				PointIdOptions: &pb.PointId_Num{
					Num: numericId,
				},
			},
			Vectors: &pb.Vectors{
				VectorsOptions: &pb.Vectors_Vector{
					Vector: &pb.Vector{
						Data: embedding,
					},
				},
			},
			Payload: payload,
		},
	}

	_, err := vs.pointsClient.Upsert(ctx, &pb.UpsertPoints{
		CollectionName: vs.collection,
		Points:         points,
	})

	return err
}

func (vs *VectorStore) Search(ctx context.Context, queryVector []float32, limit uint64) ([]*pb.ScoredPoint, error) {
	searchPoints := &pb.SearchPoints{
		CollectionName: vs.collection,
		Vector:         queryVector,
		Limit:          limit,
		WithPayload: &pb.WithPayloadSelector{
			SelectorOptions: &pb.WithPayloadSelector_Enable{
				Enable: true,
			},
		},
	}

	response, err := vs.pointsClient.Search(ctx, searchPoints)
	if err != nil {
		return nil, err
	}

	return response.Result, nil
}

func (vs *VectorStore) Close() error {
	// Close the gRPC connection if needed
	return nil
}
