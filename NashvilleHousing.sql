SELECT *
FROM 'NashvilleHousing.csv'
LIMIT 100; -- JUST LOOK TO MY DATA

--			Standartezate Date format
SELECT SaleDate, STRPTIME(SaleDate, '%B %d, %Y') AS ConvertSaleDate
FROM 'NashvilleHousing.csv' AS NashvilleHousing
LIMIT 100;

Update 'NashvilleHousing.csv'
SET SaleDate = STRPTIME(SaleDate, '%B %d, %Y')

ALTER TABLE NashvilleHousing
Add ConvertSaleDate Date;

Update 'NashvilleHousing.csv'
SET ConvertSaleDate = CONVERT(Date, SaleDate)

SELECT ConvertSaleDate, STRPTIME(SaleDate, '%B %d, %Y')
FROM NashvilleHousing
LIMIT 100;

--			Populate property Address data

SELECT * -- how mach PropertyAddress is null?
FROM 'NashvilleHousing.csv'
WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT FirstTable.ParcelID, -- find all empty cell in PropertyAddress
	FirstTable.PropertyAddress, 
	SecondTable.ParcelID, 
	SecondTable.PropertyAddress,
	ISNULL(FirstTable.PropertyAddress, SecondTable.PropertyAddress) -- Populate property Address data (fill empty cell)
FROM 'NashvilleHousing.csv' AS FirstTable
JOIN 'NashvilleHousing.csv' AS SecondTable -- join same table
ON FirstTable.ParcelID = SecondTable.ParcelID -- condition 1
AND FirstTable.UniqueID <> SecondTable.UniqueID -- condition 2
WHERE FirstTable.PropertyAddress is null; -- show empty cell

UPDATE FirstTable -- update table, now any empty cell in PropertyAddress
SET PropertyAddress = ISNULL(FirstTable.PropertyAddress, SecondTable.PropertyAddress) 
FROM 'NashvilleHousing.csv' AS FirstTable
JOIN 'NashvilleHousing.csv' AS SecondTable 
ON FirstTable.ParcelID = SecondTable.ParcelID 
AND FirstTable.UniqueID <> SecondTable.UniqueID 
WHERE FirstTable.PropertyAddress is null;

--			Breaking out Addres into Individual Colums (Adress, City and State)
--PropertyAddress
SELECT SUBSTRING(PropertyAddress, 1, -- Breaking out with 1st symbol
		CHARINDEX(',', PropertyAddress) -1 ) as Address, -- search ',' as a separator
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, -- Breaking out after separator (+1 meaning, not count the coma)
		LEN(PropertyAddress)) as Address -- to end
FROM 'NashvilleHousing.csv' AS NashvilleHousing;
-- Updating table
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--OwnerAddress 
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3), -- 1 part Address
		PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2), -- 2 part City
		PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) -- 3 part State
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--			Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM 'NashvilleHousing.cvs' AS NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2; -- shows all possible values ​​in this column

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' -- if values 'Y' then rewrite 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No' -- if values 'N' then rewrite 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   					WHEN SoldAsVacant = 'N' THEN 'No'
	   			ELSE SoldAsVacant
	   			END

--			Remove Duplicates
--The standard method for finding duplicates is to use the "" function on a column, such as UniqueID. A possible option is with a temporary table (described here)
WITH RowNumCTE AS( -- Create CTEs
SELECT *,
	ROW_NUMBER() OVER ( --generation of sequential numbers for row, OVER determines how row are numbered
	PARTITION BY ParcelID, -- divides the result set into partitions based on the specified columns
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) AS row_num --the order in which row numbers are assigned within each section
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


--			Delete Unused Columns
SELECT *
FROM 'NashvilleHousing.cvs';

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate; -- list of unused columns