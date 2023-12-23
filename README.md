# Movies BOX OFFice Data Analysis Project

## Overview

This repository contains a data analysis project based on the IMDb movies dataset sourced from Kaggle. The dataset was cleaned, enhanced with additional real details about movies, actors, writers, directors, and their nationalities. After preprocessing, an Entity-Relationship Diagram (ERD) was created, followed by mapping, normalization, and importing the cleaned data into SQL Server. Subsequently, SQL queries were developed to derive insights from the dataset.

## Dataset Description

The IMDb movies dataset contains information about movies, including details like movie name, genre, release year, actors, writers, directors, financial information, and ratings.

## Procedures
1. **Data Collecting:**
   - the IMDb movies dataset was collected from Kaggle.com

2. **Data Cleaning and Enhancement:**
   - The dataset was cleaned and enriched with actor, writer, director details, including birthdates, nationalities, and main actor information.

3. **Database Schema Creation:**
   - An ERD was designed, and mapping and normalization processes were executed to prepare the dataset for SQL Server import.

4. **Data Import and Schema Connection:**
   - The cleaned data was imported into SQL Server, and a database diagram was created, connecting entities through foreign keys.

5. **Insights and SQL Queries:**
   - A series of SQL queries were developed to derive valuable insights from the dataset. Examples include:
   
   - Top 3 profitable writers with their movies.
   - The most actors' nationalities participating in action movies.
   - Number of movies for each actor and the total average revenue.
   - Count of movies within a specified time range.
   - Top actors or directors based on the number of movies they've worked on.
   - Movie recommendations based on genre and rating range.
   - Other various queries targeting genres, average runtime, and profitability.
   
6. **Stored Procedures, Triggers, and Views:**
   - Stored procedures were created for various purposes like retrieving movie counts, recommending movies, and retrieving high-profit movies within a specific genre.
   - Triggers were implemented to prevent deletion of records if associated data exists and to avoid insertion of duplicate records.
   - Views were established to encapsulate complex queries.

## Usage

1. **Accessing Insights:**
   - Run the provided SQL queries to gain insights into the IMDb movies dataset.

2. **Further Analysis:**
   - Extend the analysis by creating additional SQL queries, procedures, views, or triggers to extract more insights or perform different analyses.

3. **Database Management:**
   - Use the SQL scripts to manage and analyze the dataset efficiently.

## Conclusion

This project showcases the process of cleaning, enhancing, and analyzing the IMDb movies dataset using SQL queries. The provided queries offer valuable insights into the movies, actors, directors, genres, profitability, and other aspects of the film industry based on the dataset.

For further details on the SQL queries, procedures, triggers, and views, refer to the SQL scripts provided in this repository.


