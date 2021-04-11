import requests
from lxml import html
import pandas as pd

page = requests.get('https://www.formula1.com/en/results.html/2021/team.html')
tree = html.fromstring(page.content)
team_sd = tree.xpath('//tr')
column_headers = []

for column in team_sd[0]:
    name = column.text_content()
    column_headers.append((name, []))

for row in range(1, len(team_sd)):
    table_tr = team_sd[row]

    column_count = 0

    for column in table_tr.iterchildren():
        data = column.text_content()
        column_headers[column_count][1].append(data)
        column_count += 1

dictionary = {title: column for (title, column) in column_headers}

team_standing = pd.DataFrame(dictionary)

# data cleaning
team_standing = team_standing.drop('', 1)
team_standing['Team'] = team_standing['Team'].str.strip()
team = {
    'Red Bull Racing Honda': 'RED BULL',
    'Mercedes': 'MERCEDES',
    'AlphaTauri Honda': 'ALPHATAURI',
    'Ferrari': 'FERRARI',
    'Williams Mercedes': 'WILLIAMS',
    'McLaren Mercedes': 'MCLAREN',
    'Alfa Romeo Racing Ferrari': 'ALFA ROMEO',
    'Haas Ferrari': 'HAAS',
    'Alpine Renault': 'ALPINE',
    'Aston Martin Mercedes': 'ASTON MARTIN',
    }

team_standing['Team'] = team_standing['Team'].map(team)
team_standing['GP'] = 'Bahrain'
team_standing['race'] = '1'

team_standing.to_csv('/Volumes/My Passport for Mac/R/F1/2021/data/team_standing.csv', index=False)



page = requests.get('https://fantasy.formula1.com/summary')
tree = html.fromstring(page.content)
fantasy_stat = tree.xpath('//div[@class = "summary-box    summary-box--most-transferred-in-by-position"]/text()')
column_headers = []
