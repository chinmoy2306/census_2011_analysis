# Project 1: Indian Population Census Analysis (2011)
## Overview
1. This repository showcases my data analysis project performed using MySQL on the Indian Population Census dataset of 2011. 
2. The dataset was obtained from “www.census2011.co.in” using web-scrapping with the help of power query and provides a comprehensive overview of the Indian population across various states and demographic factors.
## Dataset
The dataset used for this analysis consists of the following files:
- `PopByCity-Census2011.csv`: This file contains the population information with respect to all the cities in a particular state along with other details such as literacy%, sex-ratio etc.
- `PopByDistrict-Census2011.csv`: This file contains the population information with respect to all the districts in a particular state along with other details such as growth%, sex-ratio, literacy% etc.
- `PopByState-Census2011.csv`: This file contains additional informational for every state such as male%, female%, %change in population etc.
- `city.csv`: This file contains the distinct city names w.r.t each states.
- `state.csv`: This file contains the distinct state names.
- `district.csv`: This file contains the distinct district names w.r.t each states.
## Project Structure
This repository is structured as follows:
- Raw dataset files: 
1. `PopByCity-Census2011.csv`
2. `PopByDistrict-Census2011.csv`
3. `PopByState-Census2011.csv`
4. `state`
5. `district`
6. `city`
7. census_2011_analysis.sql: 
- This SQL script contains the queries used for data analysis on the 2011 Census dataset. 
- The queries cover various aspects, such as population distribution by state, district, gender and more.
- Feel free to explore the `census_2011_analysis.sql` file to view the specific queries used in this analysis.
## Usage
To reproduce the analysis or explore the dataset and code further, please follow these steps:
1.	Clone the repository:
git clone https://github.com/your-username/your-repository.git
2.	Navigate to the project directory.
3.	Set up a MySQL environment and import the csv files into the database.
4.	Execute the SQL queries from the `census_2011_analysis.sql` file in your MySQL environment to perform the analysis.
## Dependencies
The following dependencies are required to run the `census_2011_analysis.sql` file:
- MySQL server and client
## License
The dataset used in this project is sourced from “https://www.census2011.co.in” and is subject to the licensing terms provided by the dataset author.

