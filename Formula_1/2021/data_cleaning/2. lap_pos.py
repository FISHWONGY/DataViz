import pandas as pd

racePos = pd.read_csv('/Volumes/My Passport for Mac/R/F1/2021/data/lap_pos/F1_2021_racePos_race22.csv')

# racePos.loc[(racePos.driver_int == 'MZ'), 'driver_int'] = 'MAZ'

driver = {
    'VER': 'Max Verstappen',
    'HAM': 'Lewis Hamilton',
    'BOT': 'Valtteri Bottas',
    'LEC': 'Charles Leclerc',
    'GAS': 'Pierre Gasly',
    'RIC': 'Daniel Ricciardo',
    'NOR': 'Lando Norris',
    'SAI': 'Carlos Sainz',
    'ALO': 'Fernando Alonso',
    'STR': 'Lance Stroll',
    'PER': 'Sergio Perez',
    'GIO': 'Antonio Giovinazzi',
    'TSU': 'Yuki Tsunoda',
    'RAI': 'Kimi Räikkönen',
    'RUS': 'George Russell',
    'OCO': 'Esteban Ocon',
    'LAT': 'Nicholas Latifi',
    'MSC': 'Mick Schumacher',
    'MAZ': 'Nikita Mazepin',
    'VET': 'Sebastian Vettel',
    'KUB': 'Robert Kubica'
    }
racePos['driver'] = racePos['driver_int'].map(driver)

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
    'Sebastian Vettel': 'ASTON MARTIN',
    'Robert Kubica': 'ALFA ROMEO'
    }

racePos['team'] = racePos['driver'].map(team)

# check = racePos[racePos['driver'].isnull()]


racePos.to_csv('/Volumes/My Passport for Mac/R/F1/2021/data/lap_pos/F1_2021_racePos_race22.csv', index=False)
