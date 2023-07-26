SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolio Project].[dbo].NashvilleHousing


Select *
From [Portfolio Project].dbo.NashvilleHousing

--Normalizing Sale Date Format
Select SaleDate, CONVERT(Date,SaleDate)
From [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

  
Select SaleDateConverted 
From [Portfolio Project].dbo.NashvilleHousing

--Replacing Null Addresses if an Address is Assigned to Concurrent ParcelID

Select *
From [Portfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelId, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNUll(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
Join [Portfolio Project].dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNUll(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
Join [Portfolio Project].dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null


Select PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,Len(PropertyAddress)) as City
From [Portfolio Project].dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertyStreet Nvarchar(255);

Update NashvilleHousing
Set PropertyStreet =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertyCity Nvarchar(255);

Update NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,Len(PropertyAddress))
 
Select * 
From [Portfolio Project].dbo.NashvilleHousing

Select owneraddress
From [Portfolio Project].dbo.NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',','.'),3),
Parsename(Replace(OwnerAddress, ',','.'),2),
Parsename(Replace(OwnerAddress, ',','.'),1)
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerStreet Nvarchar(255);

Update NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Norming 'Y' & 'N' to 'Yes' and 'No' in "Sold as Vacant"

Select *
From [Portfolio Project].dbo.NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From [Portfolio Project].dbo.NashvilleHousing
	
Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

--Removing Duplicates

With ROWNUMCTE As(
Select *,
ROW_NUMBER() Over (
Partition BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order BY 
		UniqueID
		) row_num
From [Portfolio Project].dbo.NashvilleHousing
--order by ParcelID
)

Select *
From ROWNUMCTE
Where row_num > 1
Order by PropertyAddress

Select * 
From [Portfolio Project].dbo.NashvilleHousing