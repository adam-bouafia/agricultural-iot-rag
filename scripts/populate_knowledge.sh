#!/bin/bash
# Script to populate the knowledge base with comprehensive agricultural data

echo "📚 Populating Agricultural Knowledge Base..."
echo ""

cd "$(dirname "$0")/.."

# Export environment variables
export QDRANT_URL=localhost:6334
export OLLAMA_URL=http://localhost:11434
export EMBEDDING_API_URL=http://localhost:11434
export EMBEDDING_MODEL=nomic-embed-text

# Array of agricultural knowledge
knowledge=(
    # Potato cultivation
    "Potatoes require soil moisture between 60-80% for optimal growth and tuber development"
    "Optimal temperature for potato growth is 15-20°C during day and 10-15°C at night"
    "Irrigate potatoes when soil moisture drops below 50% to prevent crop stress"
    "Potatoes need 500-700mm of water throughout the growing season"
    "High temperatures above 30°C can damage potato tubers and reduce yield quality"
    
    # Tomato cultivation
    "Tomatoes need consistent watering to prevent blossom end rot and fruit cracking"
    "Optimal soil moisture for tomatoes is 65-85% during fruit development"
    "Tomato plants require 25-38mm of water per week during peak growing season"
    "Temperature range of 21-27°C is ideal for tomato fruit set and development"
    "Calcium deficiency causes blossom end rot in tomatoes - maintain soil pH 6.0-6.8"
    
    # Corn cultivation
    "High nitrogen fertilizer is recommended for corn during vegetative growth stage"
    "Corn requires heaviest irrigation during silking and tasseling stages"
    "Optimal soil moisture for corn is 70-90% during pollination period"
    "Corn water stress during flowering can reduce yields by 20-50%"
    "Sweet corn needs consistent moisture to develop tender kernels"
    
    # General irrigation
    "Drip irrigation is 90% efficient compared to 65% for sprinkler systems"
    "Early morning irrigation (4-10 AM) minimizes water loss from evaporation"
    "Avoid evening watering as it promotes fungal diseases on crops"
    "Soil moisture sensors should be placed at root zone depth for accurate readings"
    "Sandy soils require more frequent irrigation than clay soils"
    
    # Soil health
    "Low soil moisture below 40% leads to crop stress and reduced photosynthesis"
    "Waterlogged soil (>95% moisture) causes root oxygen deprivation and disease"
    "Regular monitoring of soil pH prevents nutrient lockout issues"
    "Organic matter improves soil water retention capacity"
    "Soil compaction reduces water infiltration and root growth"
    
    # Pest and disease management
    "High humidity above 80% combined with warm temperatures promotes fungal diseases"
    "Leaf wetness duration over 6 hours increases disease risk significantly"
    "Good air circulation reduces pest pressure and disease spread"
    "Crop rotation prevents soil-borne disease buildup"
    "Integrated Pest Management reduces chemical pesticide dependency"
    
    # Fertilization
    "Nitrogen application should match crop growth stage demands"
    "Phosphorus is critical during early root development and flowering"
    "Potassium improves drought tolerance and disease resistance"
    "Split fertilizer applications reduce nutrient leaching"
    "Soil testing every 2-3 years guides fertilization decisions"
    
    # Weather-based recommendations
    "Do not irrigate if heavy rain (>25mm) is forecast within 24 hours"
    "Strong winds increase crop water demands through transpiration"
    "Cloudy days reduce irrigation needs by 20-30% compared to sunny days"
    "Frost protection requires overhead irrigation during freezing events"
    "High solar radiation increases evapotranspiration rates"
    
    # Crop-specific nutrients
    "Leafy vegetables require high nitrogen for green growth"
    "Fruiting crops need balanced NPK with extra potassium during fruiting"
    "Root crops benefit from phosphorus and potassium over nitrogen"
    "Legumes fix their own nitrogen but need phosphorus and potassium"
    "Micronutrients (Zn, Fe, Mn) are essential despite small quantities needed"
    
    # Alert conditions
    "Immediate irrigation required when soil moisture drops below 40% for most crops"
    "Emergency action needed if temperature exceeds 35°C for potatoes"
    "Apply shade cloth when UV index exceeds 10 during heat waves"
    "Increase monitoring frequency when humidity exceeds 85%"
    "Activate frost protection when temperature forecast drops below 2°C"
)

# Add each piece of knowledge
count=0
for item in "${knowledge[@]}"; do
    echo "Adding: $item"
    ./bin/cli add-knowledge "$item"
    if [ $? -eq 0 ]; then
        ((count++))
    else
        echo "⚠️  Failed to add knowledge item"
    fi
    sleep 0.5  # Small delay to avoid overwhelming the system
done

echo ""
echo "✅ Successfully added $count knowledge items to the database!"
echo ""
echo "🔍 Test search with:"
echo "   ./bin/cli search \"potato irrigation\""
echo "   ./bin/cli search \"tomato temperature\""
echo "   ./bin/cli search \"fertilizer\""
