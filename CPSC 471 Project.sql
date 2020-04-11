-- CREATE DATABASE cpsc471_project;
USE cpsc471_project; /*Selects cpsc471_project Database */

/* *********************************************************** Table of Contents ***********************************************************
-Entities
-Relationships
-Populating the 
-Endpoints 
*/

/* *********************************************************** Entities *********************************************************** */
CREATE TABLE Person (
LastName VARCHAR (255), /*LastName is a String type with a 255 char limit*/
FirstName VARCHAR(255), 
Address  VARCHAR(255),
AmountDonated FLOAT, /*AmountDonated is of float type. For example: 10.44*/
CONSTRAINT PersonAmountDonatedMustBePositive CHECK(AmountDonated>=0), /*Constraint: AmountDonated must be greater than 0. "PersonAmountDonatedMustBePositive" is a name that is arbitrarily chosen. When we insert a negative value for AmountDonated, an error message will contain "PersonAmountDonatedMustBePositive", which is a self-explantory error message. If we don't specify this, it will display a default error message, which isn't as self-explantory*/
SSN VARCHAR(11) NOT NULL, /*Specifies that this attribute cannot be a null value. Format: XXX-XXX-XXX. */
CONSTRAINT SSNLengthMustBeEleven CHECK(Length(SSN) = 11), /*SSN must be a 11 digit character*/
PRIMARY KEY (SSN) /*Specifies SSN to be a Primary Key*/
);

CREATE TABLE PhoneNo( /*PhoneNo is a multi-valued attribute, so need to create a table for it*/
PhoneNo VARCHAR (12) UNIQUE, /*Format: XXX-XXX-XXXX*/
SSN VARCHAR(11) NOT NULL,
CONSTRAINT PhoneSSNLengthMustBeEleven CHECK(Length(SSN) = 11),
FOREIGN KEY (SSN) REFERENCES Person(SSN) /*Reference SSN as a Foriegn Key in Person*/
);

CREATE TABLE FoodDonatedPerson( /*Multi-valued attribute of Person*/
FoodName VARCHAR(255) UNIQUE, /*Unique ensures that the same two FoodNames cannot exist in the database, like a PK*/
SSN VARCHAR(11) NOT NULL,
CONSTRAINT FoodDonatedPersonSSNLengthMustBeEleven CHECK(Length(SSN) = 11),
FOREIGN KEY (SSN) REFERENCES Person(SSN)
);

CREATE TABLE KitchenStaff( /*Inherited from Volunteer*/
Salary FLOAT,
CONSTRAINT SalaryMustBePositive CHECK(Salary>=0),
YearsWorked INT,
CONSTRAINT YearsWorkedMustBePositive CHECK(YearsWorked>0 AND YearsWorked<100),
StaffSSN VARCHAR(11) PRIMARY KEY REFERENCES Person (SSN) /*References SSN in Person. This is an indicator that this entity is inherited from Person*/
);

/* Removed for the sake of simplicity
CREATE TABLE Volunteer( /*Inherited from Person
VolunteerSSN VARCHAR(11) PRIMARY KEY REFERENCES Person (SSN)
);
*/

CREATE TABLE Parent( /*Inherited from Volunteer*/
PreferredVolunteerRole VARCHAR(255),
ParentSSN VARCHAR(11) PRIMARY KEY REFERENCES Person (SSN)
);

CREATE TABLE Nutritionist( /*Inherited from Volunteer*/
PresentationRating VARCHAR(255),
YearsOfExperience VARCHAR(255),
NutritionistSSN VARCHAR(11) PRIMARY KEY REFERENCES Person (SSN)
);

CREATE TABLE Chef( /*Inherited from Volunteer*/
PresentationRating VARCHAR(255),
YearsOfExperience VARCHAR(255),
ChefSSN VARCHAR(11) PRIMARY KEY REFERENCES Person (SSN)
);

CREATE TABLE Student( /*Inherited from Person*/
Age INT,
CONSTRAINT AgeMustBePositive CHECK(Age>0 AND Age<120),
Gender VARCHAR(1),
CONSTRAINT GenderMustBeMOrF CHECK (Gender = 'M' OR Gender = 'F'),
ParentPhoneNo VARCHAR(12),
StudentSSN VARCHAR(11) PRIMARY KEY REFERENCES Person (SSN)
);

CREATE TABLE Card( /*Weak entity of Student*/
StudentID INT NOT NULL PRIMARY KEY AUTO_INCREMENT, /*Another way of specifying that this attribute is a PK. Increments ID by 1. So, if a new card is created, that ID is 1, then if another is created, it is 2, then 3, and so on*/
Balance FLOAT,
CONSTRAINT BalanceMustBePositive CHECK(Balance>=0),
DateCreated DATE, /*Format: *YYYY-MM-DD*/
CONSTRAINT DateCreateMustBeBeforeApril2020 CHECK(DateCreated < '2020-05-01'), /*DateCreated has to be before 2020-05-01*/
DailyAllowanceReached BOOLEAN, /*Has only 2 possible values, True(1) or false(0)*/
StudentSSN VARCHAR(11) NOT NULL,
FOREIGN KEY (StudentSSN) REFERENCES Student(StudentSSN)
ON DELETE CASCADE /*If Student is deleted, then Card will be deleted as well*/
);

CREATE TABLE MedicalReport( /*Weak entity of Student*/
ReportNo INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
LactoseIntolerant BOOLEAN,
CeliacDisease BOOLEAN,
HighCholesterol BOOLEAN,
BMIGreaterThan25 BOOLEAN,
StudentSSN VARCHAR(11) NOT NULL,
FOREIGN KEY (StudentSSN) REFERENCES Student(StudentSSN)
ON DELETE CASCADE
);

CREATE TABLE Company( 
CompanyID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
PhoneNo VARCHAR(12),
Address VARCHAR(255),
NoOfEmployees INT,
CONSTRAINT NoOfEmployeesMustBePositive CHECK(NoOfEmployees>=0),
AmountDonated FLOAT,
CONSTRAINT CompanyAmountDonatedMustBePositive CHECK(AmountDonated>=0)
);

CREATE TABLE FoodDonatedCompany( /*Multi-valued attribute of Company*/
FoodName VARCHAR(255) UNIQUE,
CompanyID INT NOT NULL,
FOREIGN KEY (CompanyID) REFERENCES Company(CompanyID)
);

CREATE TABLE Ingredient(
IngredientID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
ExpiryDate DATE,
SupplierName VARCHAR(255),
Cost FLOAT,
CONSTRAINT CostMustBePositive CHECK(Cost>=0),
StorageLocation VARCHAR(255),
Mass FLOAT,
CONSTRAINT MassMustBePositive CHECK(Mass>=0)
);

CREATE TABLE MealOption( /*Endpoint: Store Meal Option info*/
MealOptionID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
MealName VARCHAR(255) UNIQUE,
MealPrice FLOAT,
CONSTRAINT MealPriceMustBePositive CHECK(MealPrice>=0),
ParentSSN VARCHAR(11),
NutritionistSSN VARCHAR(11) NOT NULL,
IngredientID INT NOT NULL,
FOREIGN KEY (ParentSSN) REFERENCES Parent(ParentSSN),
FOREIGN KEY (NutritionistSSN) REFERENCES Nutritionist(NutritionistSSN), 
FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);

CREATE TABLE MealType( /*Multi-valued attribute of MealOptions*/
MealType VARCHAR(15), /*Can only be 'LowSodium', 'LowSugar', 'LowCarbohydrate', 'GlutenFree', or 'DairyFree'*/
CONSTRAINT MustBeValidMealType CHECK(MealType = 'LowSodium' OR MealType = 'LowSugar' OR MealType = 'LowCarbohydrate' OR MealType = 'GlutenFree' OR MealType = 'DairyFree' OR MealType),
MealOptionID INT NOT NULL,
FOREIGN KEY (MealOptionID) REFERENCES MealOption(MealOptionID)
);

CREATE TABLE NutritionalContent(
NutritionID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
Sugar INT,
CONSTRAINT SugarMustBePositive CHECK(Sugar>=0),
Calories INT,
CONSTRAINT CaloriesMustBePositive CHECK(Calories>=0),
Cholesterol INT,
CONSTRAINT CholesterolMustBePositive CHECK(Cholesterol>=0),
Lactose INT,
CONSTRAINT LactoseMustBePositive CHECK(Lactose>=0),
Gluten INT,
CONSTRAINT GlutenMustBePositive CHECK(Gluten>=0),
MealOptionID INT NOT NULL,
FOREIGN KEY (MealOptionID) REFERENCES MealOption(MealOptionID)

);

CREATE TABLE Macronutrients( /*Weak entity of NutritionalContent*/
Fats INT NOT NULL PRIMARY KEY,
CONSTRAINT FatMustBePositive CHECK(Fats>=0),
Proteins INT,
CONSTRAINT ProteinsMustBePositive CHECK(Proteins>=0),
Carbohydrates INT,
CONSTRAINT CarbohydatesMustBePositive CHECK(Carbohydrates>=0),
NutritionID INT NOT NULL,
FOREIGN KEY (NutritionID) REFERENCES NutritionalContent(NutritionID)
ON DELETE CASCADE
);

CREATE TABLE Micronutrients( /*Weak entity of NutritionalContent*/
VitaminA INT NOT NULL PRIMARY KEY,
CONSTRAINT VitaminAMustBePositive CHECK(VitaminA>=0),
VitaminB INT,
CONSTRAINT VitaminBMustBePositive CHECK(VitaminB>=0),
VitaminD INT,
CONSTRAINT VitaminDMustBePositive CHECK(VitaminD>=0),
VitaminC INT,
CONSTRAINT VitaminCMustBePositive CHECK(VitaminC>=0),
Zinc INT,
CONSTRAINT ZincMustBePositive CHECK(Zinc>=0),
Iron INT,
CONSTRAINT IronMustBePositive CHECK(Iron>=0),
Sodium INT,
CONSTRAINT SodiumMustBePositive CHECK(Sodium>=0),
Potassium INT,
CONSTRAINT PotassiumMustBePositive CHECK(Potassium>=0),
Calcium INT,
CONSTRAINT CalciumMustBePositive CHECK(Calcium>=0),
VitaminK INT,
CONSTRAINT VitaminKMustBePositive CHECK(VitaminK>=0),
NutritionID INT NOT NULL,
FOREIGN KEY (NutritionID) REFERENCES NutritionalContent(NutritionID)
ON DELETE CASCADE
);

/* *********************************************************** Relationships *********************************************************** */

/*Example of what this should look like*/
CREATE TABLE CompanyPurchases(
TotalCost FLOAT,
CONSTRAINT TotalCostBePositive CHECK(TotalCost>=0),
CompanyID INT NOT NULL,
IngredientID INT NOT NULL,
FOREIGN KEY (CompanyID) REFERENCES Company(CompanyID),
FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);

/*Start of Mohammad's part*/
/*Prepares*/
CREATE TABLE Prepares(
StaffSSN VARCHAR(11) NOT NULL,
MealOptionID INT NOT NULL,
FOREIGN KEY (StaffSSN) REFERENCES KitchenStaff(StaffSSN),
FOREIGN KEY (MealOptionID) REFERENCES MealOption(MealOptionID)
);
/*PersonPurchases*/
CREATE TABLE PersonPurchases(
SSN VARCHAR(11) NOT NULL,
IngredientID INT NOT NULL,
TotalCost FLOAT,
CONSTRAINT TotalCostIsPositive CHECK(TotalCost>=0),
FOREIGN KEY (SSN) REFERENCES Person(SSN),
FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);
/*ChefEducates*/
CREATE TABLE ChefEducates(
StudentSSN VARCHAR(11) NOT NULL,
ChefSSN VARCHAR(11) NOT NULL,
FOREIGN KEY (StudentSSN) REFERENCES Student(StudentSSN),
FOREIGN KEY (ChefSSN) REFERENCES Chef(ChefSSN)
);

/*NutritionistEducates*/
CREATE TABLE NutritionistEducates(
StudentSSN VARCHAR(11) NOT NULL,
NutritionistSSN VARCHAR(11) NOT NULL,
FOREIGN KEY (StudentSSN) REFERENCES Student(StudentSSN),
FOREIGN KEY (NutritionistSSN) REFERENCES Nutritionist(NutritionistSSN)
);
/*End of Mohammad's part*/

/* *********************************************************** Populating the Database *********************************************************** */

/*Entities go here. Please don't put relationships here :) */
/*Example of inserting an inherited entity into database*/
/*Entity: Student. Entry #: 1*/
INSERT INTO Student (Age, Gender,ParentPhoneNo, StudentSSN) 
VALUES(10, 'M', '403-016-0000', '100-006-000');
/*Need to insert its inherited attributes as well*/
INSERT INTO Person (SSN, LastName, FirstName, Address, AmountDonated) 
VALUES('100-006-000', 'Smith', 'Frank', "Address 60", 0);
/*Need to insert its PhoneNumber Entity as well*/
INSERT INTO PhoneNo (PhoneNo, SSN) 
VALUES('403-006-0000', '100-006-000');
/*Entity: Student. Entry #: 2*/
INSERT INTO Student (Age, Gender,ParentPhoneNo, StudentSSN) 
VALUES(11, 'F', '403-016-0001',  '100-006-001');
INSERT INTO Person (SSN, LastName, FirstName, Address, AmountDonated) 
VALUES('100-006-001', 'Lewis', 'Jessica', "Address 61", 0);
INSERT INTO PhoneNo (PhoneNo, SSN) 
VALUES('403-006-0001', '100-006-001');
/*Entity: Student. Entry #: 3*/
INSERT INTO Student (Age, Gender,ParentPhoneNo, StudentSSN) 
VALUES(9, 'M', '403-016-0002',  '100-006-002');
INSERT INTO Person (SSN, LastName, FirstName, Address, AmountDonated) 
VALUES('100-006-002', 'Smithie', 'Adam', "Address 62", 0);
INSERT INTO PhoneNo (PhoneNo, SSN) 
VALUES('403-006-0002', '100-006-002');
INSERT INTO PhoneNo (PhoneNo, SSN) /*Multi-valued attribute, can have multiple phone numbers*/
VALUES('403-006-0003', '100-006-002');

/*Example of inserting a weak entity into database*/
/*Entity: Card. Entry #: 1*/ 
INSERT INTO Card (Balance, DateCreated, DailyAllowanceReached, StudentSSN) 
VALUES(21.50, '2019-03-01', 0, '100-006-000');
/*Entity: Card. Entry #: 2*/ 
INSERT INTO Card (Balance, DateCreated, DailyAllowanceReached, StudentSSN) 
VALUES(31.50, '2019-03-21', 0, '100-006-001');
/*Entity: Card. Entry #: 3*/ 
INSERT INTO Card (Balance, DateCreated, DailyAllowanceReached, StudentSSN) 
VALUES(1.50, '2019-03-11', 0, '100-006-002');

/*Entity: Nutrtionist. Entry #: 1*/
INSERT INTO Nutritionist (NutritionistSSN, PresentationRating, YearsOfExperience) 
VALUES('100-004-000', 7, 2 );
INSERT INTO Person (SSN, LastName, FirstName, Address, AmountDonated) 
VALUES('100-004-000', 'Mith', 'Rank', "Address 40", 0);
INSERT INTO PhoneNo (PhoneNo, SSN) 
VALUES('403-004-0000', '100-004-000');
/*Entity: Student. Entry #: 2*/
INSERT INTO Nutritionist (NutritionistSSN, PresentationRating, YearsOfExperience) 
VALUES('100-004-001', 5, 1);
INSERT INTO Person (SSN, LastName, FirstName, Address, AmountDonated) 
VALUES('100-004-001', 'With', 'Pank', "Address 41", 10);
INSERT INTO PhoneNo (PhoneNo, SSN) 
VALUES('403-004-0001', '100-004-001');
/*Entity: Student. Entry #: 3*/
INSERT INTO Nutritionist (NutritionistSSN, PresentationRating, YearsOfExperience) 
VALUES('100-004-002', 9, 5);
INSERT INTO Person (SSN, LastName, FirstName, Address, AmountDonated) 
VALUES('100-004-002', 'Pith', 'Brad', "Address 42", 13);
INSERT INTO PhoneNo (PhoneNo, SSN) 
VALUES('403-004-0002', '100-004-002');

/*Entity: Nutrtionist. Entry #: 1*/
INSERT INTO Ingredient (IngredientID, ExpiryDate, SupplierName, Cost, StorageLocation, Mass) 
VALUES(1, '2020-01-21', 'Fruitto', 20.5, 'Attic', 200);
/*Entity: Student. Entry #: 2*/
INSERT INTO Ingredient (IngredientID, ExpiryDate, SupplierName, Cost, StorageLocation, Mass) 
VALUES(2, '2020-02-21', 'Veggieso', 10.5, 'Basement', 100);
/*Entity: Student. Entry #: 3*/
INSERT INTO Ingredient (IngredientID, ExpiryDate, SupplierName, Cost, StorageLocation, Mass) 
VALUES(3, '2020-03-21', 'Salado', 90.5, 'Basement', 220);

/*Entity: Company. Entry #: 1*/
INSERT INTO Company (PhoneNo, Address, NoOfEmployees, AmountDonated) 
VALUES('403-007-0000', 'Address 70', 10, 120.5);
/*Entity: Company. Entry #: 2*/
INSERT INTO Company (PhoneNo, Address, NoOfEmployees, AmountDonated) 
VALUES('403-007-0001', 'Address 71', 20, 20.5);
/*Entity: Company. Entry #: 3*/
INSERT INTO Company (PhoneNo, Address, NoOfEmployees, AmountDonated) 
VALUES('403-007-0002', 'Address 72', 90, 220.5);

/*Start of Boma's part*/
/*Let me know if you have any questions :)*/

/*Entity: Chef. Entry #: 1*/
INSERT INTO Chef (PresentationRating, YearsOfExperience, ChefSSN)
	VALUES('7.5', '12', '100-005-000');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
    VALUES('Ramthay', 'Gordon', "Address 50", 0, '100-005-000');
INSERT INTO PhoneNo (PhoneNo, SSN)
    VALUES('403-005-000', '100-005-000');
/*Entity: Chef. Entry #: 2*/
INSERT INTO Chef (PresentationRating, YearsOfExperience, ChefSSN)
	VALUES('9.5', '26', '100-005-001');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
    VALUES('Ramsay', 'Nordon', "Address 51", 20, '100-005-001');
INSERT INTO PhoneNo (PhoneNo, SSN)
    VALUES('403-005-001', '100-005-001');
/*Entity: Chef. Entry #: 3*/
INSERT INTO Chef (PresentationRating, YearsOfExperience, ChefSSN)
	VALUES('5', '5', '100-005-002');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
    VALUES('Ramhay', 'Bordon', "Address 52", 80, '100-005-002');
INSERT INTO PhoneNo (PhoneNo, SSN)
    VALUES('403-005-002', '100-005-002');

/*Entity: Parent. Entry #: 1*/
INSERT INTO Parent (PreferredVolunteerRole, ParentSSN)
	VALUES('Server', '100-003-000');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
	VALUES('Jones', 'Jeff', "Address 30", 0, '100-003-000');
INSERT INTO PhoneNo (PhoneNo, SSN)
	VALUES('403-003-000', '100-003-000');
/*Entity: Parent. Entry #: 2*/
INSERT INTO Parent (PreferredVolunteerRole, ParentSSN)
	VALUES('Kitchen Staff', '100-003-001');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
	VALUES('Kittles', 'Kerry', "Address 31", 130, '100-003-001');
INSERT INTO PhoneNo (PhoneNo, SSN)
	VALUES('403-003-001', '100-003-001');
/*Entity: Parent. Entry #: 3*/
INSERT INTO Parent (PreferredVolunteerRole, ParentSSN)
	VALUES('Taster', '100-003-002');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
	VALUES('Pierce', 'Paul', "Address 32", 95, '100-003-002');
INSERT INTO PhoneNo (PhoneNo, SSN)
	VALUES('403-003-002', '100-003-002');

/*Entity: KitchenStaff. Entry #: 1*/
INSERT INTO KitchenStaff (Salary, YearsWorked, StaffSSN)
	VALUES(55000, 7, '100-001-000');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
	VALUES('Johnson', 'Dwayne', "Address 10", 85, '100-001-000');
INSERT INTO PhoneNo (PhoneNo, SSN)
	VALUES('403-001-000', '100-001-000');
/*Entity: KitchenStaff. Entry #: 2*/
INSERT INTO KitchenStaff (Salary, YearsWorked, StaffSSN)
	VALUES(25000, 2, '100-001-001');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
	VALUES('Flair', 'Rick', "Address 11", 120, '100-001-001');
INSERT INTO PhoneNo (PhoneNo, SSN)
	VALUES('403-001-001', '100-001-001');
/*Entity: KitchenStaff. Entry #: 3*/
INSERT INTO KitchenStaff (Salary, YearsWorked, StaffSSN)
	VALUES(30000, 4, '100-001-002');
INSERT INTO Person (LastName, FirstName, Address, AmountDonated, SSN)
	VALUES('Micheals', 'Shawn', "Address 12", 0, '100-001-002');
INSERT INTO PhoneNo (PhoneNo, SSN)
	VALUES('403-001-002', '100-001-002');

/*Entity: FoodDonatedCompany. Entry #: 1*/
INSERT INTO FoodDonatedCompany (CompanyID, FoodName)
	VALUES(1, 'Carrots');
/*Entity: FoodDonatedCompany. Entry #: 2*/
INSERT INTO FoodDonatedCompany (CompanyID, FoodName)
	VALUES(2, 'Grapes');
/*Entity: FoodDonatedCompany. Entry #: 3*/
INSERT INTO FoodDonatedCompany (CompanyID, FoodName)
	VALUES(3, 'Flour');

/*Entity: FoodDonatedPerson. Entry #: 1*/
INSERT INTO FoodDonatedPerson (SSN, FoodName)
	VALUES('100-003-002', 'Apples');
/*Entity: FoodDonatedPerson. Entry #: 2*/
INSERT INTO FoodDonatedPerson (SSN, FoodName)
	VALUES('100-003-000', 'Beans');
/*Entity: FoodDonatedPerson. Entry #: 3*/
INSERT INTO FoodDonatedPerson (SSN, FoodName)
	VALUES('100-005-001', 'Chocolate');

/*Example of inserting a strong entity into database*/
/*Entity: MealOption. Entry #: 1*/
INSERT INTO MealOption (MealName, MealPrice, ParentSSN,  NutritionistSSN, IngredientID) 
VALUES('Apple Salad', 1.50, '100-003-000', '100-004-000', 1);
/*MealOption has a MealType, which is a multi-valued attribute. To say 'MealOptionID 1 is both LowSodium and LowSugar, we code it as follows:*/
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSodium', 1);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSugar', 1);
/*Entity: MealOption. Entry #: 2*/
INSERT INTO MealOption (MealName, MealPrice, ParentSSN, NutritionistSSN, IngredientID) 
VALUES('Grape Salad', 2.50, '100-003-001', '100-004-001', 2);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('DairyFree', 2);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSugar', 2);
/*Entity: MealOption. Entry #: 3*/
INSERT INTO MealOption (MealName, MealPrice, ParentSSN, NutritionistSSN, IngredientID) 
VALUES('Lemon Salad', 2.30, '100-003-002', '100-004-002', 3);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('DairyFree', 3);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSugar', 3);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSodium', 3);

/*Entity: NutrtionalContent. Entry #: 1*/
INSERT INTO NutritionalContent (NutritionID, Sugar, Calories, Cholesterol, Lactose, Gluten, MealOptionID)
	VALUES(1, 0, 45, 0, 0, 0, 1);
/*Entity: NutrtionalContent. Entry #: 2*/
INSERT INTO NutritionalContent (NutritionID, Sugar, Calories, Cholesterol, Lactose, Gluten, MealOptionID)
	VALUES(2, 5, 75, 10, 10, 5, 2);
/*Entity: NutrtionalContent. Entry #: 3*/
INSERT INTO NutritionalContent (NutritionID, Sugar, Calories, Cholesterol, Lactose, Gluten, MealOptionID)
	VALUES(3, 1, 75, 0, 5, 0, 3);

/*Entity: Macronutrients. Entry #: 1*/
INSERT INTO Macronutrients(Fats, Proteins, Carbohydrates, NutritionID)
	VALUES(10, 25, 55, 1);
/*Entity: Macronutrients. Entry #: 2*/
INSERT INTO Macronutrients(Fats, Proteins, Carbohydrates, NutritionID)
	VALUES(15, 20, 45, 2);
/*Entity: Macronutrients. Entry #: 3*/
INSERT INTO Macronutrients(Fats, Proteins, Carbohydrates, NutritionID)
	VALUES(20, 35, 65, 3);

/*Entity: Micronutrients. Entry #: 1*/
INSERT INTO Micronutrients (VitaminA, VitaminB, VitaminD, VitaminC, Zinc, Iron, Sodium, Potassium, Calcium, VitaminK, NutritionID)
	VALUES(10, 70, 0, 100, 70, 10, 40, 30, 40, 20, 1);
/*Entity: Micronutrients. Entry #: 2*/
INSERT INTO Micronutrients (VitaminA, VitaminB, VitaminD, VitaminC, Zinc, Iron, Sodium, Potassium, Calcium, VitaminK, NutritionID)
	VALUES(0, 60, 10, 80, 70, 10, 35, 25, 35, 20, 2);
/*Entity: Micronutrients. Entry #: 3*/
INSERT INTO Micronutrients (VitaminA, VitaminB, VitaminD, VitaminC, Zinc, Iron, Sodium, Potassium, Calcium, VitaminK, NutritionID)
	VALUES(15, 40, 30, 100, 70, 10, 50, 60, 20, 45, 3);

/*Entity: MedicalReport. Entry #: 1*/
INSERT INTO MedicalReport (ReportNo, LactoseIntolerant, CeliacDisease, HighCholesterol, BMIGreaterThan25, StudentSSN)
	VALUES(1, 1, 0, 0, 0, '100-006-000');
/*Entity: MedicalReport. Entry #: 2*/
INSERT INTO MedicalReport (ReportNo, LactoseIntolerant, CeliacDisease, HighCholesterol, BMIGreaterThan25, StudentSSN)
	VALUES(2, 0, 1, 1, 1, '100-006-001');
/*Entity: MedicalReport. Entry #: 3*/
INSERT INTO MedicalReport (ReportNo, LactoseIntolerant, CeliacDisease, HighCholesterol, BMIGreaterThan25, StudentSSN)
	VALUES(3, 1, 1, 1, 0, '100-006-002');

/*End of Boma's part*/

/*Relationships go here. Please don't put entities here :)*/
/*Example of inserting a relatioship into database*/
/*Relationship: Purchases. Entry #: 1*/
INSERT INTO CompanyPurchases (TotalCost, CompanyID, IngredientID) 
VALUES(50, 1, 1);
/*Relationship: Purchases. Entry #: 2*/
INSERT INTO CompanyPurchases (TotalCost, CompanyID, IngredientID) 
VALUES(20, 2, 2);
/*Relationship: Purchases. Entry #: 3*/
INSERT INTO CompanyPurchases (TotalCost, CompanyID, IngredientID) 
VALUES(52, 3, 3);

/*Start of Mohammad's part.*/
/*Relationship: Prepares. Entry #: 1*/
INSERT INTO  Prepares (StaffSSN, MealOptionID)
VALUES('100-001-000', 1);
/*Relationship: Prepares. Entry #: 2*/
INSERT INTO  Prepares (StaffSSN, MealOptionID)
VALUES('100-001-001', 2);
/*Relationship: Prepares. Entry #: 3*/
INSERT INTO  Prepares (StaffSSN, MealOptionID)
VALUES('100-001-002', 3);

/*Relationship: PersonPurchases. Entry #: 1*/
INSERT INTO  PersonPurchases (SSN, IngredientID, TotalCost)
VALUES('100-006-000', 1, 1.00);
/*Relationship: PersonPurchases. Entry #: 2*/
INSERT INTO  PersonPurchases (SSN, IngredientID, TotalCost)
VALUES('100-006-001', 2, 1.20);
/*Relationship: PersonPurchases. Entry #: 3*/
INSERT INTO  PersonPurchases (SSN, IngredientID, TotalCost)
VALUES('100-006-002', 2, 1.40);

/*Relationship: ChefEducates. Entry #: 1*/
INSERT INTO ChefEducates (StudentSSN, ChefSSN)
VALUES('100-006-000', '100-005-000');
/*Relationship: ChefEducates. Entry #: 2*/
INSERT INTO ChefEducates (StudentSSN, ChefSSN)
VALUES('100-006-001', '100-005-001');
/*Relationship: ChefEducates. Entry #: 3*/
INSERT INTO ChefEducates (StudentSSN, ChefSSN)
VALUES('100-006-002', '100-005-002');

/*Relationship: NutritionistEducates. Entry #: 1*/
INSERT INTO NutritionistEducates (StudentSSN, NutritionistSSN)
VALUES('100-006-000', '100-004-000');
/*Relationship: NutritionistEducates. Entry #: 2*/
INSERT INTO NutritionistEducates (StudentSSN, NutritionistSSN)
VALUES('100-006-001', '100-004-001');
/*Relationship: NutritionistEducates. Entry #: 3*/
INSERT INTO NutritionistEducates (StudentSSN, NutritionistSSN)
VALUES('100-006-002', '100-004-002');
/*End of Mohammad's part*/

/* *********************************************************** Endpoints *********************************************************** */
/*To do: The 9 endpoints should go here. Storing has already been completed in the Entity section*/

/*Endpoint: Update Meal Option information*/
UPDATE MealOption
SET MealName = 'Banana Salad',  MealPrice= 1.25
WHERE MealOptionID = 1;
/*Can update MealType as well*/
UPDATE MealType
SET MealType = 'GlutenFree'
WHERE MealOptionID = 1 AND MealType = 'LowSodium';

/*Endpoint: Retrieve Parent information*/
SELECT ParentSSN, Pe.LastName, Pe.FirstName, Pe.Address, Pe.AmountDonated, Ph.PhoneNo
FROM Parent, Person AS Pe, PhoneNo as Ph
WHERE ParentSSN = Pe.SSN AND Ph.SSN = ParentSSN;

/*Endpoint: Retrieving Meal Option information*/
SELECT MealOption.MealOptionID, MealName, MealPrice, MealType
FROM MealType, MealOption
WHERE MealOption.MealOptionID = MealType.MealOptionID;

/*Start of Annelyse's part*/
/*Let me know if you have any questions :)*/

/*First time is tricky. See my example of retrieving Parent info from the database above (roughly 10 lines above this line). When you've coded the first one, run the script. 
If you're retrieving the relevent attributes (as shown in Parent Query), then you're on the right track and can proceed to code the remaining ones :)*/
/*Endpoint: Retrieve Company information*/

/*Endpoint: Retrieve Card information*/

/*Endpoint: Retrieve Medical Report information*/

/*Endpoint: Retrieve Ingredient information*/

/*Endpoint: Retrieve Nutritional Content info*/

/*Endpoint: Retrieve Macronutrients info*/

/*End of Annelyse's part*/

/*ToDo
Issues with duplicates in MealTypes
*/