import requests
from lxml import html
import pandas as pd

page = requests.get('https://www.formula1.com/en/results.html/2021/drivers.html')
tree = html.fromstring(page.content)
driver_sd = tree.xpath('//tr')
column_headers = []

for column in driver_sd[0]:
    name = column.text_content()
    column_headers.append((name, []))

for row in range(1, len(driver_sd)):
    table_tr = driver_sd[row]

    column_count = 0

    for column in table_tr.iterchildren():
        data = column.text_content()
        column_headers[column_count][1].append(data)
        column_count += 1

dictionary = {title: column for (title, column) in column_headers}

driver_standing = pd.DataFrame(dictionary)
driver_standing = driver_standing.drop('', 1)
driver_standing['Car'] = driver_standing['Car'].str.strip()
driver_standing['Driver'] = driver_standing['Driver'].str.strip()
driver_standing['Driver'] = driver_standing['Driver'].str.replace(" ", "")
driver_standing['Driver'] = driver_standing['Driver'].str.replace("\n", " ")
# driver_standing = driver_standing.replace({'Driver': {" ": "", '\n': " "}})

driver_standing[['First', 'Last', 'Int']] = driver_standing.Driver.str.split(" ", expand=True, )
driver_standing['Driver'] = driver_standing['First'] + " " + driver_standing['Last']
driver_standing = driver_standing.drop(['First', 'Last'], axis=1)

team = {
    'Max Verstappen': 'RED BULL',
    'Lewis Hamilton': 'MERCEDES',
    'Valtteri Bottas': 'MERCEDES',
    'Charles Leclerc': 'FERRARI',
    'Pierre Gasly': 'ALPHATAURI',
    'Daniel Ricciardo': 'MCLAREN',
    'Lando Norris': 'MCLAREN',
    'Carlos Sainz': 'FERRARI',
    'Fernando Alonso': 'ALPINE',
    'Lance Stroll': 'ASTON MARTIN',
    'Sergio Perez': 'RED BULL',
    'Antonio Giovinazzi': 'ALFA ROMEO',
    'Yuki Tsunoda': 'ALPHATAURI',
    'Kimi Räikkönen': 'ALFA ROMEO',
    'George Russell': 'WILLIAMS',
    'Esteban Ocon': 'ALPINE',
    'Nicholas Latifi': 'WILLIAMS',
    'Mick Schumacher': 'HAAS',
    'Nikita Mazepin': 'HAAS',
    'Sebastian Vettel': 'ASTON MARTIN'
    }

driver_standing['Car'] = driver_standing['Driver'].map(team)

driver_standing['GP'] = 'Bahrain'
driver_standing['race'] = '1'

driver_standing.to_csv('/Volumes/My Passport for Mac/R/F1/2021/data/driver_standing.csv', index=False)
