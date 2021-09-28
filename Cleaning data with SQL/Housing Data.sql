/*
Cleaning Data in SQL Queries
*/

SELECT * FROM [Portfolio Project]..NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------


 -- Standardize Date Format

 SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
 FROM [Portfolio Project]..NashvilleHousing

 ALTER TABLE [Portfolio Project]..NashvilleHousing 
 ADD SaleDateConverted DATE;
 
 UPDATE NashvilleHousing
 SET SaleDateConverted = CONVERT(DATE, SaleDate)
 FROM [Portfolio Project]..NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

 SELECT *
 FROM [Portfolio Project]..NashvilleHousing
 --WHERE PropertyAddress IS NULL
 ORDER BY ParcelID



 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM [Portfolio Project]..NashvilleHousing a
 JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

 SELECT PropertyAddress
 FROM [Portfolio Project]..NashvilleHousing

 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
 FROM [Portfolio Project]..NashvilleHousing
 

-- PropertySplitAdress

 ALTER TABLE [Portfolio Project]..NashvilleHousing 
 ADD PropertySplitAddress NVARCHAR(255);
 
 UPDATE NashvilleHousing
 SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
 FROM [Portfolio Project]..NashvilleHousing


 -- PropertySplitCity

 ALTER TABLE [Portfolio Project]..NashvilleHousing 
 ADD PropertySplitCITY NVARCHAR(255);
 
 UPDATE NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
 FROM [Portfolio Project]..NashvilleHousing


 -- Owner Address using PARSENAME

 SELECT 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
 FROM [Portfolio Project]..NashvilleHousing

 -- OwnerSplitAddress
 ALTER TABLE [Portfolio Project]..NashvilleHousing 
 ADD OwnerSplitAddress NVARCHAR(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 FROM [Portfolio Project]..NashvilleHousing


 -- PropertySplitCity

 ALTER TABLE [Portfolio Project]..NashvilleHousing 
 ADD OwnerSplitCity NVARCHAR(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
 FROM [Portfolio Project]..NashvilleHousing

 -- PropertySplitState
  ALTER TABLE [Portfolio Project]..NashvilleHousing 
 ADD OwnerSplitState NVARCHAR(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 FROM [Portfolio Project]..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant
	     END
FROM [Portfolio Project]..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM [Portfolio Project]..NashvilleHousing
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * 
FROM [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
