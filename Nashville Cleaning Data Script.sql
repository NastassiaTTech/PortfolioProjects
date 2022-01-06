SELECT *
FROM [dbo].[NashvilleHousing];

--Standardized Date Format
SELECT SaleDateConverted, CONVERT(Date,[SaleDate]) as SalesDate
from [dbo].[NashvilleHousing];

--Update [dbo].[NashvilleHousing]
--SET SaleDate = CONVERT (Date, SaleDate) as SalesDate

ALTER Table [dbo].[NashvilleHousing]
ADD SaleDateConverted Date;

Update [dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT (Date, SaleDate) ;

--

SELECT *
FROM [dbo].[NashvilleHousing]
--WHERE PropertyAddress is NULL
Order By ParcelID;

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a 
JOIN [dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null ;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a 
JOIN [dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null ;

--Breaking out address Into Individual colums(Address, city, state)

SELECT PropertyAddress
FROM [dbo].[NashvilleHousing];

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as city
FROM [dbo].[NashvilleHousing];
--or you recieve the some data back. The one above prevents you to manually count the strings.
SELECT 
SUBSTRING(PropertyAddress,1,18) as address
,SUBSTRING(PropertyAddress,20,LEN(PropertyAddress)) as city
FROM [dbo].[NashvilleHousing];


--
ALTER Table [dbo].[NashvilleHousing]
ADD PropertySplitAddress NVARCHAR(255);

Update [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER Table [dbo].[NashvilleHousing]
ADD PropertySplitCity NVARCHAR(255);

Update [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))  

Select*
from [dbo].[NashvilleHousing];

---Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from [dbo].[NashvilleHousing]
Group By SoldAsVacant
order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
from [dbo].[NashvilleHousing];

Update [dbo].[NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END;

----Remove Duplicates
WITH  Row_NUMCTE AS (
select *,
		ROW_NUMBER() OVER (
		PARTITION BY [ParcelID],[PropertyAddress],[SaleDate],[SalePrice],[LegalReference]
		ORDER BY 
		UniqueID
		) row_num
FROM [dbo].[NashvilleHousing]
)
DELETE
FROM Row_NumCTE
WHERE row_num >1;

---Droping Tables
ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN [OwnerAddress],[TaxDistrict],[PropertyAddress],[SaleDate];