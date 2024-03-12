/*
Data Cleaning project of Nashville Housing
Skills used: Windows Functions, Data Formatting, Data Standardization, Joints, Alter Tables, Update Tables, Delete Duplicates, CTE

*/

--Data Transfer
EXEC sp_rename 'Sheet1$', 'NashvilleHousing'
SELECT *
FROM Project1..NashvilleHousing


--Standardize date format
SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM Project1..NashvilleHousing

UPDATE Project1..NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)


--Adding the converted date
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Project1..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM Project1..NashvilleHousing


--Populating address data
SELECT *
FROM Project1..NashvilleHousing
WHERE PropertyAddress is null

Select *
FROM Project1..NashvilleHousing
ORDER BY ParcelID


--We do a self Join
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM  Project1..NashvilleHousing a
JOIN  Project1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Populate the self join 
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM  Project1..NashvilleHousing a
JOIN  Project1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out data (SUBSTRING)
SELECT PropertyAddress
FROM Project1..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address --First part of the address
FROM Project1..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address   --Second part of the address
FROM Project1..NashvilleHousing


--Adding the column PropertySplitAddres
ALTER TABLE NashvilleHousing
ADD PropertySplitAddres nvarchar(255);

UPDATE Project1..NashvilleHousing
SET PropertySplitAddres = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 


--Adding the column PropertySplitCity
ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE Project1..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 


--Breaking out data (PARSENAME)
SELECT *
FROM Project1..NashvilleHousing
WHERE owneraddress is null

SELECT
PARSENAME(REPLACE(owneraddress, ',', '.'), 3),
PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
FROM Project1..NashvilleHousing


--Adding the column OwnerSplitCity
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE Project1..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Project1..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE Project1..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1)


--Standard data for column SoldAsVacant
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM Project1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM Project1..NashvilleHousing

UPDATE Project1..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END


--Deleting Duplicates
--Making a partition
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM Project1..NashvilleHousing
ORDER BY ParcelID


--CTE to identify duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM Project1..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
 

--Deleting the duplicates found
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM Project1..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--Deleting Unnecessary Columns
ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict

SELECT *
FROM Project1..NashvilleHousing
