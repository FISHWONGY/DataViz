import pandas as pd
import requests
from lxml import html
import pandas as pd

myAnimedf = pd.DataFrame(columns=['Rank', 'Title', 'Score', 'Your Score', 'Status'])

for i in range(0, 10000, 50):
    page = requests.get('https://myanimelist.net/topanime.php?limit=' + str(i))
    tree = html.fromstring(page.content)
    myanime = tree.xpath('//tr')
    column_headers = []

    for column in myanime[0]:
        name = column.text_content()
        column_headers.append((name, []))

    for row in range(1, len(myanime)):
        table_tr = myanime[row]

        column_count = 0

        for column in table_tr.iterchildren():
            data = column.text_content()
            column_headers[column_count][1].append(data)
            column_count += 1

    dictionary = {title: column for (title, column) in column_headers}

    outputdf = pd.DataFrame(dictionary)

    myAnimedf = myAnimedf.append(outputdf,  ignore_index=True)


# Get col. name for loop
df_header = list(myAnimedf.columns.values)

# Clean every col
for h in df_header:
    myAnimedf[h] = myAnimedf[h].str.strip()

# Clean title, get everything before 'Watch'
myAnimedf['Title'] = myAnimedf['Title'].str.split('Watch').str[0]
myAnimedf = myAnimedf[['Rank', 'Title', 'Score']]


