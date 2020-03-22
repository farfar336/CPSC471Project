CREATE DATABASE cpsc471_project;
USE cpsc471_project; /*Selects cpsc471_project Database */
/* Notes:
-First thing I recommend when you start on this is to run the entire script to see how it works. To do that, press Ctrl + All and click the Lightning icon (Without the I) on the top left.
-When you've ran this script once. Comment out lines 1 and 2, you will never need to execute these lines anymore.
-You'll notice that you get no errors when running this. So, when your part has been implemented, do a test run to make sure it has no errors as well.
-It is likely that you will get errors and have to modify the script and re-run it. But, you can't run this more than once because the tables have already been created. So
you have to select all tables under 'SCHEMAS', right click and drop all tables. Now you can run the script again. This won't make sense when reading it the first time, so come back to this
when you've attempted to implement your part
-Search up your name to find which section you should cover
-Please do not modify code that is outside your start and end comments. If you'd like to make a change, message me :)
*/

/* ------------------------------------------------------------ Table of Contents ------------------------------------------------------------
-Entities: Line 20 to 210
-Relationships: Line 211 to 240
-Populating the Database Line 241 to 466
-Endpoints Line 466 to 505
*/

/* ------------------------------------------------------------ Entities ------------------------------------------------------------*/
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

/* ------------------------------------------------------------ Relationships ------------------------------------------------------------ */
/*To do: Exactly the same thing with entities, but now, with relationships. Follow the RM on draw.io*/
/*The following relationships need to be inserted:
-Prepares
-PersonPurchases
-ChefEducates
-NutritionistEducates
*/

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
/*Follow the RM on draw.io. Let me know if you have any questions :)*/

/*When you create your first table, I'd like you to send me a picture of your work so that I can check it. If the first one looks good, then you can proceed to do the remaining ones :)*/
/*Prepares*/
/*PersonPurchases*/
/*ChefEducates*/
/*NutritionistEducates*/

/*End of Mohammad's part*/

/* ------------------------------------------------------------ Populating the Database ------------------------------------------------------------ */
/*To do: Insert 3 entries of entity and relationships in the database*/

/*The following needs to be populated:
Entities
-Chef
-FoodDonatedCompany
-FoodDonatedPerson
-KitchenStaff
-Macronutrients
-MedicalReport
-Micronutrients
-NutrtionalContent
-Parent
-Volunteer

Relationships
-Prepares
-PersonPurchases
-ChefEducates
-NutritionistEducates
*/

/*Advice: Each subclass of person will have a PhoneNo and SSN. There will be problems inserting these into the database as it is difficult for our us to keep track of all this info
in our head. For example, if you insert the SSN 100-000-000 for one student, and then you want to insert SSN for parent, you might forget that you already used 100-000-000 and attempt it.
To prevent such duplicate entries, we will assign each subclass in person a numberm like so:

Kitchen Staff: 1
Volunteer: 2
Parent: 3
Nutritionist: 4
Chef: 5
Student: 6

If we want to insert a new entry for Student, then it would look like this: PhoneNo: 403-006-0000 and SSN: 100-006-000. Next student entry would be: PhoneNo: 403-006-0001 and SSN: 100-006-001.
Here is another example, for Chef:  PhoneNo: 403-005-0000 and SSN: 100-005-000. Next Chef entry would be: PhoneNo: 403-005-0001 and SSN: 100-005-001
We'll do the same thing for address. So, for Student: Address 60, next entry: Address 61. For Chef: Address 50, next entry: Address 51
Also, we need to insert multiple phone numbers. I've already done this for the student entity, so just one will be enough for the other subclasses.
*/

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

/*Example of inserting a strong entity into database*/
/*Entity: MealOption. Entry #: 1*/
INSERT INTO MealOption (MealName, MealPrice, NutritionistSSN, IngredientID) 
VALUES('Apple Salad', 1.50, '100-004-000', 1);
/*MealOption has a MealType, which is a multi-valued attribute. To say 'MealOptionID 1 is both LowSodium and LowSugar, we code it as follows:*/
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSodium', 1);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSugar', 1);
/*Entity: MealOption. Entry #: 2*/
INSERT INTO MealOption (MealName, MealPrice, NutritionistSSN, IngredientID) 
VALUES('Grape Salad', 2.50, '100-004-001', 2);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('DairyFree', 2);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSugar', 2);
/*Entity: MealOption. Entry #: 3*/
INSERT INTO MealOption (MealName, MealPrice, NutritionistSSN, IngredientID) 
VALUES('Lemon Salad', 2.30, '100-004-002', 3);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('DairyFree', 3);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSugar', 3);
INSERT INTO MealType (MealType, MealOptionID) 
VALUES('LowSodium', 3);

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
/*Note: Volunteer entity was removed for the sake of simplicity. So, entities like Chef who was a subclass of Volunteer, is now a subclass of Person*/

/* First time is tricky. See my example of inserting Nutritionist into database above (roughly 70 lines above this line). When you've coded first entry, run the script. If you get no errors,
then you're on the right track and can proceed to code the remaining ones :)*/
/*Entity: Chef. Entry #: 1*/
/*Entity: Chef. Entry #: 2*/
/*Entity: Chef. Entry #: 3*/

/*Entity: Parent. Entry #: 1*/
/*Entity: Parent. Entry #: 2*/
/*Entity: Parent. Entry #: 3*/

/*Entity: KitchenStaff. Entry #: 1*/
/*Entity: KitchenStaff. Entry #: 2*/
/*Entity: KitchenStaff. Entry #: 3*/

/*Entity: FoodDonatedCompany. Entry #: 1*/
/*Entity: FoodDonatedCompany. Entry #: 2*/
/*Entity: FoodDonatedCompany. Entry #: 3*/

/*Entity: FoodDonatedPerson. Entry #: 1*/
/*Entity: FoodDonatedPerson. Entry #: 2*/
/*Entity: FoodDonatedPerson. Entry #: 3*/

/*Entity: Macronutrients. Entry #: 1*/
/*Entity: Macronutrients. Entry #: 2*/
/*Entity: Macronutrients. Entry #: 3*/

/*Entity: Micronutrients. Entry #: 1*/
/*Entity: Micronutrients. Entry #: 2*/
/*Entity: Micronutrients. Entry #: 3*/

/*Entity: NutrtionalContent. Entry #: 1*/
/*Entity: NutrtionalContent. Entry #: 2*/
/*Entity: NutrtionalContent. Entry #: 3*/

/*Entity: MedicalReport. Entry #: 1*/
/*Entity: MedicalReport. Entry #: 2*/
/*Entity: MedicalReport. Entry #: 3*/

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

/*First time is tricky. See my example of inserting CompanyPurchases into database above (roughly 10 lines above this line). When you've coded first entry, run the script. If you get no errors,
then you're on the right track and can proceed to code  the remaining ones :)*/
/*Relationship: Prepares. Entry #: 1*/
/*Relationship: Prepares. Entry #: 2*/
/*Relationship: Prepares. Entry #: 3*/

/*Relationship: PersonPurchases. Entry #: 1*/
/*Relationship: PersonPurchases. Entry #: 2*/
/*Relationship: PersonPurchases. Entry #: 3*/

/*Relationship: ChefEducates. Entry #: 1*/
/*Relationship: ChefEducates. Entry #: 2*/
/*Relationship: ChefEducates. Entry #: 3*/

/*Relationship: NutritionistEducates. Entry #: 1*/
/*Relationship: NutritionistEducates. Entry #: 2*/
/*Relationship: NutritionistEducates. Entry #: 3*/

/*End of Mohammad's part*/

/* ------------------------------------------------------------ Endpoints ------------------------------------------------------------ */
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
Test
*/