# 🚗 Car Price Prediction

## 📌 Overview
This project predicts used car prices using machine learning.

## 📊 Dataset
Includes features like:
- brand
- car model
- car price
- kms_driven
- fuel_type
- city
- car_age 

## ⚙️ Steps
- Data Cleaning
- Data  Preprocessing
- EDA
- Feature Engineering
- Model Building (Random Forest)
- Model Evaluetion
- Feature Importence
- Model Saving (Reusable Model)
  .Saved Files
  .car_price_model.pkl → Trained model
  .brand_encoder.pkl → Brand encoding
  .fuel_encoder.pkl → Fuel type encoding
  .x_train_columns.pkl → Feature columns used during training
  .target_mean.pkl → Stores mean car prices per model (used for target encoding)

## 📈 Results
- R² Score: 0.94
- Good prediction accuracy

## ▶️ How to Run
```bash
pip install -r requirements.txt
python model.py 
