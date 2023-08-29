Select SoldAsVacant, count(soldasvacant)
FROM BootcampDA.dbo.NashvilleHousing
group by SoldAsVacant

--CLEANING DATA IN SQL QUERIES 

Select *
from BootcampDA.dbo.NashvilleHousing

--STANDARDIZE DATE FORMAT 

ALTER TABLE  NashvilleHousing
ADD SaleDateConverted date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--POPULATE PTOPETY ADDRESS DATA 


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,COALESCE(a.PropertyAddress, b.PropertyAddress) as PropertyAdresNew
from BootcampDA.dbo.NashvilleHousing a
JOIN BootcampDA.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
order by a.ParcelID


UPDATE a
SET PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
from BootcampDA.dbo.NashvilleHousing a
JOIN BootcampDA.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--BREAKING ADDRESS INTO INDIVIDUAL COLUMNS 

SELECT SUBSTRING(propertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(propertyaddress)) as City
FROM BootcampDA.dbo.NashvilleHousing


ALTER TABLE  NashvilleHousing
ADD PropertyAddressNew Nvarchar(255)

UPDATE NashvilleHousing
SET PropertyAddressNew = SUBSTRING(propertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE  NashvilleHousing
ADD PropertyCity Nvarchar(255)

UPDATE NashvilleHousing
SET Propertycity = SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(propertyaddress))

--SPLIT OWNERADDRESS
Select PARSENAME(REPLACE(owneraddress,',','.'),3),PARSENAME(REPLACE(owneraddress,',','.'),2),PARSENAME(REPLACE(owneraddress,',','.'),1)
from BootcampDA.dbo.NashvilleHousing

-- ADD NEW COLUMNS FOR SPLITADDRESS

ALTER TABLE  NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)
ALTER TABLE  NashvilleHousing
ADD OwnerSplitcity Nvarchar(255)
ALTER TABLE  NashvilleHousing
ADD OwnerSplitState Nvarchar(255)


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2)


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)



-- REMOVE DUPLICATE  

WITH DuplicateTable AS 
(
SELECT
 ROW_NUMBER() OVER 
	(PARTITION BY parcelID,
				  propertyaddress,
				  saleprice,saledate,
				  legalreference 
				  ORDER BY
					uniqueId)
					row_nums,*
FROM BootcampDA.dbo.NashvilleHousing

)

SELECT *
FROM DuplicateTable
WHERE row_nums > 1

DELETE 
FROM DuplicateTable
WHERE row_nums > 1



-- DELETED UNUSED COLUMNS 


ALTER TABLE BootcampDA.dbo.NashvilleHousing
DROP COLUMN owneraddress,taxdistrict,propertyaddress

ALTER TABLE BootcampDA.dbo.NashvilleHousing
DROP COLUMN Saledate
