import requests
from lxml import html
import pandas as pd

page = requests.get('https://www.formula1.com/en/racing/2021/Italy/Timetable.html')
tree = html.fromstring(page.content)
race_table = tree.xpath('//tr')
column_headers = []

for column in race_table[0]:
    name = column.text_content()
    column_headers.append((name, []))

for row in range(1, len(race_table)):
    table_tr = race_table[row]

    column_count = 0

    for column in table_tr.iterchildren():
        data = column.text_content()
        column_headers[column_count][1].append(data)
        column_count += 1

dictionary = {title: column for (title, column) in column_headers}

full_schedule = pd.DataFrame(dictionary)
full_schedule = full_schedule.reset_index().T.reset_index().T
full_schedule = full_schedule.drop(0, 1)

full_schedule.columns = ['event', 'time']
full_schedule['event'] = full_schedule['event'].str.strip()
full_schedule['time'] = full_schedule['time'].str.strip()

