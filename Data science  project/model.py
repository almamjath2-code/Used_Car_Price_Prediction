#WITHOUT PIPLINE CHEKTHE MODEL
import pandas as pd
import joblib



# 1.Load 
train_columns = joblib.load("x_train_columns.pkl")# this already x train  column load without y train (car price column)
le_brand = joblib.load("brand_encoded.pkl")# alrady leble encoded data colum load
le_fuel = joblib.load("fuel_type_encoded.pkl")#alrady leble encoded data colum load
car_name_model  = joblib.load("target_mean.pkl")#alrady leble encoded data colum load
model  = joblib.load("USED_CAR_price_model .pkl")# rf model for pridict load



#2 . inputs for pridict and if you give lower case same type all lower case /
#  no copy and past frome direct csv fill

print("==== Used Car Price Prediction ====")

new_car = { 
   "brand" : input("Car Brand: "),
   "car_model_name":input("car_model_name:"),
    "kms_driven":int(input("kms_driven:" )),
    "fuel_type" :input("fuel_type:"),
    "year_of_manufacture":int(input("year_of_manufacture:")),
    "city": input("city:")

}

#3. this do just transform like this not do fit_transform becouse aledy did this

if new_car["brand"] in le_brand.classes_:#2 le_brand is here
    brand_encoded = le_brand.transform([new_car["brand"]])[0]
else:
    # Not seen before, assign a default value (e.g., -1) or global mean
    brand_encoded = -1

if new_car["fuel_type"] in le_fuel.classes_:
    fuel_encoded = le_fuel.transform([new_car["fuel_type"]])[0]
else:
    fuel_encoded = -1

# this get metot use for target encoded and 1.car_name_model is here
target_model_name = car_name_model.get(new_car["car_model_name"], car_name_model.mean())





car_age = 2024 - new_car['year_of_manufacture']
#4.
# Create base dataframe "model_target_encoded":target_model_name/
#  when you save what have name same type have in input_df example  this  "model_target_encoded"
input_df = pd.DataFrame([{
    "kms_driven": new_car['kms_driven'],#3 is here enter
    "car_age": car_age,
    "brand_encoded": brand_encoded,
    "fuel_type_encoded": fuel_encoded,
    "model_target_encoded":target_model_name


}])




# Create all city columns = 0
for col in train_columns:  #one hot methot
    if col.startswith("city_"):
        input_df[col] = 0

# Set correct city = 1
city_col = "city_" + new_car['city']
if city_col in input_df.columns:
    input_df[city_col] = 1


#5

input_df = input_df.reindex(columns=train_columns, fill_value=0)#4 is here enter the 

#6. final pritict
price = model.predict(input_df)[0] #5 is here enter
print(f"Predicted Price: ₹{price:,.0f}")