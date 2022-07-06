--remove timestmp from date
select SaleDate from [Nashville Housing];

select CONVERT(date,SaleDate) from [Nashville Housing];

--Add a new column in the table

update [Nashville Housing]
set SaleDate=CONVERT(date,SaleDate);
ALTER TABLE [Nashville Housing] 
Add SalesDateConverted date
;

UPDATE [Nashville Housing]
set SalesDateConverted=CONVERT(date,SaleDate)
;
select SalesDateConverted from [Nashville Housing];

--populate PropertyAddress Data
select ParcelID,PropertyAddress,
CASE 
WHEN PropertyAddress is null then 'Null'
ELSE PropertyAddress
END AS AddressOrNot
from [Nashville Housing];
--check null values

select * from [Nashville Housing] where PropertyAddress is null;

--implement joins to select property addresses and parcel id
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing] a
join [Nashville Housing] b
on b.ParcelID=a.ParcelID

where a.PropertyAddress is null
and b.UniqueID<>a.UniqueID 
;
--ALTER TABLE [Nashville Housing]
--ADD PropAddressUpdated

update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing] a
join [Nashville Housing] b
on b.ParcelID=a.ParcelID

and
b.[UniqueID ]<>a.[UniqueID ]

;

SELECT PropertyAddress from [Nashville Housing]
where PropertyAddress is null;

--View the Formatting of Property Address
select PropertyAddress from [Nashville Housing];
--view only the address before the column
select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1) ) as Street
from [Nashville Housing];

ALTER TABLE [Nashville Housing]
ADD Street nvarchar(255) null;
--Set Street to everything to the left of comma from PropertyAddress field
UPDATE [Nashville Housing]
set Street=(SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1))
;

select Street from [Nashville Housing];
--Add City Column to the table from Property Address(everything to the right of the ,)

ALTER TABLE [Nashville Housing]
ADD City nvarchar(255) null;

--Populate the City Column
UPDATE [Nashville Housing]
set City=(SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)))
;
select City from [Nashville Housing];

--Rename the Street Column to  PropertyStreet Column and City Column to PropertyCity  Column

sp_rename  '[Nashville Housing].Street','PropertyStreet','COLUMN';
sp_rename  '[Nashville Housing].City','PropertyCity','COLUMN';



SELECT * from [Nashville Housing]

--SPLIT Owners Address
--SPLIT Owner Name to First Name and Last name
select OwnerName from [Nashville Housing];
select SUBSTRING(OwnerName,1,CHARINDEX(',',OwnerName,1)-1) as LastName,
SUBSTRING(OwnerName,CHARINDEX(',',OwnerName)+1,LEN(OwnerName)) as FirstName
from [Nashville Housing];

--First Name
ALTER TABLE [Nashville Housing]
ADD OwnerFirstName nvarchar(255) null;
--Last Name
ALTER TABLE [Nashville Housing]
ADD OwnerLastName nvarchar(255) null;


UPDATE [Nashville Housing]
set OwnerLastName=(SUBSTRING(OwnerName,1,CHARINDEX(',',OwnerName,1)));

UPDATE [Nashville Housing]
set OwnerFirstName=(SUBSTRING(OwnerName,CHARINDEX(',',OwnerName)+1,LEN(OwnerName)));





update [Nashville Housing]
set OwnerLastName=replace(OwnerLastName,',',' ')
WHERE OwnerLastName is not null;

select OwnerFirstName,OwnerLastName from [Nashville Housing];


select OwnerAddress from [Nashville Housing];
select RIGHT(OwnerAddress,2) from [Nashville Housing];

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState nvarchar(255) null;

ALTER TABLE [Nashville Housing]
ADD OwnerCity nvarchar(255) null;

ALTER TABLE [Nashville Housing]
ADD OwnersAddress nvarchar(255) null;

--POPULATE THE Owner State column
UPDATE [Nashville Housing]
set OwnerSplitState=RIGHT(OwnerAddress,2);

--POPULATE THE OWNER ADDRESS
UPDATE [Nashville Housing]
set OwnersAddress=SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1);

select OwnerAddress from [Nashville Housing];
select OwnersAddress from [Nashville Housing];



UPDATE [Nashville Housing]
set OwnerCity=SUBSTRING(OwnerCity,1,CHARINDEX(',',OwnerCity))
;

UPDATE [Nashville Housing]
set OwnerCity=REPLACE(OwnerCity,',','')
;

select OwnerCity from [Nashville Housing];
sp_rename  '[Nashville Housing].OwnerSplitState','OwnerState','COLUMN';

--Changing the values in SoldAsVacant Column
--Checking the presence of null values
select SoldAsVacant from [Nashville Housing] where SoldAsVacant is null;
--check for values in the column
select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) from [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2
;
--NOTICE THE Y AND N VALUES instead of Yes and No
--LETS REPLACE THEM BY Yes and No respectively

select
CASE 
WHEN SoldAsVacant like 'Y' then 'Yes'
WHEN SoldAsVacant like 'N' then 'No'
ELSE SoldAsVacant
END AS SoldVacant
from [Nashville Housing];

UPDATE [Nashville Housing]
set SoldAsVacant=CASE
WHEN SoldAsVacant like 'Y' then 'Yes'
WHEN SoldAsVacant like 'N' then 'No'
ELSE SoldAsVacant
END
;

--create a partition in sql

WITH HousingCTE AS (
select *, ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference

ORDER BY 
UniqueID ASC
) AS HousingData
from [Nashville Housing]
)
select * from HousingCTE where HousingData>1;

--Now delete these duplicates  using Common Table Expression(CTE)
WITH HousingCTE AS (
select *, ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference

ORDER BY 
UniqueID ASC
) AS HousingData
from [Nashville Housing]
)
delete from HousingCTE where HousingData>1;

-- DELETE Columns that are not user friendly

ALTER TABLE [Nashville Housing]
DROP COLUMN PropertyAddress,OwnerName,OwnerAddress,SaleDate;
select * from [Nashville Housing];

WITH PersonalDetails AS 
( SELECT OwnerFirstName,OwnerLastName,OwnerState,PropertyStreet,PropertyCity
from [Nashville Housing]
)

SELECT * from PersonalDetails;

sp_rename '[NashvilleHousing].SalesDateConverted','SalesDate';

SELECT SalesDateConverted from [Nashville Housing];




