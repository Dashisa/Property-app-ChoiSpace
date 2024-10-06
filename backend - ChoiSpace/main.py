from fastapi import FastAPI, HTTPException, status, Depends
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import uvicorn
import joblib
import numpy as np
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel, Field, EmailStr
from typing import Optional
from bson import ObjectId
import bcrypt
import certifi
from typing import List

app = FastAPI()

origins = [
    "http://localhost:3000",
    "http://localhost:3001"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOADS_DIR = "./uploads"
Path(UPLOADS_DIR).mkdir(parents=True, exist_ok=True)

# DB Configurations
MONGODB_CONNECTION_URL = "mongodb+srv://sampleUser:111222333AB@cluster0.tyn2v.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
client = AsyncIOMotorClient(MONGODB_CONNECTION_URL, tlsCAFile=certifi.where())
db = client["property_db"]
user_collection = db["users"]
property_collection = db["properties"]

# Model for signup request
class UserSignUpRequest(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    full_name: str = Field(..., min_length=3, max_length=100)
    email: EmailStr
    contact_number: str = Field(..., min_length=10, max_length=15)
    password: str = Field(..., min_length=8, max_length=100)
    role: str = Field(..., pattern="^(Buyer|Seller)$")

# Model for user response
class UserResponse(BaseModel):
    username: str
    full_name: str
    email: EmailStr
    contact_number: str
    role: str

def hash_password(password: str) -> bytes:
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password

# Verify Password
def verify_password(plain_password: str, hashed_password: bytes) -> bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password)

@app.post("/signup")
async def signup_user(user_data: UserSignUpRequest):
    try:
        # Check if user already exists
        existing_user = await user_collection.find_one({"email": user_data.email})
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered.")

        # Hash the password before storing it
        hashed_password = hash_password(user_data.password)

        # Create a new user document
        user_document = {
            "username": user_data.username,
            "full_name": user_data.full_name,
            "email": user_data.email,
            "contact_number": user_data.contact_number,
            "password": hashed_password,
            "role": user_data.role,
        }

        # Insert the new user into the database
        await user_collection.insert_one(user_document)

        return JSONResponse(content={"message": "User registered successfully."}, status_code=201)
    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)
    
# Sign-In Model
class SignInModel(BaseModel):
    username: str
    password: str


class SignInResponseModel(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: dict
# Verify Password
# def verify_password(plain_password, hashed_password):
#     return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password)

@app.post("/signin")
async def sign_in(signin_data: SignInModel):
    try:
        print(signin_data)
        # Find the user by username
        user = await user_collection.find_one({"username": signin_data.username})
        print(user)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Check if the password matches
        if not verify_password(signin_data.password, user["password"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect password"
            )

        access_token = "324frewfsf34"
        refresh_token = ""
        # User is successfully authenticated
        return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user": {
            "_id": str(user["_id"]),
            "username": user["username"],
            "full_name": user["full_name"],
            "email": user["email"],
            "contact_number": user["contact_number"],
            "created_at": user.get("created_at", ""),
            "role": user.get("role", ""),
        }
    }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )
    
@app.get("/user/{username}", response_model=UserResponse)
async def get_user_by_username(username: str):
    try:
        # Find the user by username
        user = await user_collection.find_one({"username": username})

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Return the user data, excluding the password
        return UserResponse(
            username=user["username"],
            full_name=user["full_name"],
            email=user["email"],
            contact_number=user["contact_number"],
            role=user["role"]
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

# Properies 
class Property(BaseModel):
    name: str
    property_type: str
    address: str
    owner: str
    city: str
    area: int
    bedrooms: int
    bathrooms: int
    stories: int
    mainroad: int
    guestroom: int
    basement: int
    hotwaterheating: int
    airconditioning: int
    parking: int
    prefarea: int
    is_sold: bool = False
    image_url: Optional[str] = None
    model_url: Optional[str] = None

@app.post("/properties", status_code=201)
async def create_property(property_data: Property):
    try:
        print(property_data)
        # Prepare the property data document
        property_document = property_data.dict()
        
        # Insert the property into the database
        result = await property_collection.insert_one(property_document)
        
        # Return the ID of the newly created property
        return {"message": "Property created successfully.", "property_id": str(result.inserted_id)}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/properties", response_model=List[Property])
async def get_all_properties():
    try:
        # Fetch all properties from the database
        properties = await property_collection.find().to_list(length=None)
        return properties
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)
    
@app.get("/properties/{property_id}", response_model=Property)
async def get_property_by_id(property_id: str):
    try:
        # Find the property by its ID
        property = await property_collection.find_one({"_id": ObjectId(property_id)})
        
        if property is None:
            raise HTTPException(status_code=404, detail="Property not found")
        
        return property
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/properties/owner/{owner}", response_model=List[Property])
async def get_properties_by_owner(owner: str):
    try:
        # Find properties by owner
        properties = await property_collection.find({"owner": owner}).to_list(length=None)
        
        if not properties:
            raise HTTPException(status_code=404, detail="No properties found for this owner")
        
        return properties
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

class UpdateProperty(BaseModel):
    name: Optional[str] = None
    property_type: Optional[str] = None
    address: Optional[str] = None
    owner: Optional[str] = None
    city: Optional[str] = None
    area: Optional[int] = None
    bedrooms: Optional[int] = None
    bathrooms: Optional[int] = None
    stories: Optional[int] = None
    mainroad: Optional[int] = None
    guestroom: Optional[int] = None
    basement: Optional[int] = None
    hotwaterheating: Optional[int] = None
    airconditioning: Optional[int] = None
    parking: Optional[int] = None
    prefarea: Optional[int] = None
    is_sold: Optional[bool] = None
    image_url: Optional[str] = None
    model_url: Optional[str] = None

@app.put("/properties/update_by_address/{address}", status_code=200)
async def update_property_by_address(address: str, property_data: UpdateProperty):
    try:
        # Prepare the update document by excluding fields that are not provided
        update_data = {k: v for k, v in property_data.dict().items() if v is not None}

        if not update_data:
            raise HTTPException(status_code=400, detail="No data provided to update")
        
        # Update the property in the database using the address
        result = await property_collection.update_one({"address": address}, {"$set": update_data})

        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Property not found")

        return {"message": "Property updated successfully."}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

# Model for prediction request
class PropertyPredictionRequest(BaseModel):
    area: int
    bedrooms: int
    bathrooms: int
    stories: int
    mainroad: int
    guestroom: int
    basement: int
    hotwaterheating: int
    airconditioning: int
    parking: int
    prefarea: int

# Load model
def load_model(model_path):
    model = joblib.load(model_path)
    return model

# Make prediction
def make_prediction(model, input_data):
    input_data_as_numpy_array = np.asarray(input_data)
    input_data_reshaped = input_data_as_numpy_array.reshape(1, -1)
    prediction = model.predict(input_data_reshaped)
    return prediction

@app.post("/propertyPrediction")
async def predict_info(request: PropertyPredictionRequest):
    try:
        # Load the model
        model_path = 'model_real.joblib'
        model = load_model(model_path)

        # Extract data from the request
        input_data = [
            request.area, request.bedrooms, request.bathrooms, request.stories, 
            request.mainroad, request.guestroom, request.basement, 
            request.hotwaterheating, request.airconditioning, request.parking, 
            request.prefarea
        ]
        
        # Make prediction
        prediction = make_prediction(model, input_data)
        prediction_json = prediction.tolist()  # Convert numpy array to list for JSON serialization
        
        return {"prediction": prediction_json}
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

if __name__ == "__main__":
    uvicorn.run(app, host="localhost", port=8000)
