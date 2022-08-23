import pandas as pd

race1 = pd.read_csv('/Volumes/My Passport for Mac/R/F1/2021/data/team_standing/team_standing.csv')
race1['pts_until_lastRace'] = 0
race1['pts_this_week'] = race1['PTS']

race2 = pd.read_csv('/Volumes/My Passport for Mac/R/F1/2021/data/team_standing/team_standing_race2.csv')
race2 = race2.merge(race1[['Team', 'pts_this_week']], how='left', left_on='Team', right_on='Team')
race2 = race2.rename(columns={'pts_this_week': "pts_until_lastRace"})
race2['pts_this_week'] = race2['PTS'] - race2['pts_until_lastRace']

race = race1.append(race2)
race.to_csv('/Volumes/My Passport for Mac/R/F1/2021/data/team_standing.csv', index=False)

###############################################################
###############################################################
###############################################################
# Run this only
import pandas as pd
race = pd.read_csv('/Volumes/My Passport for Mac/R/F1/2021/data/team_standing.csv')

# team_standing_raceX.csv. X每次+1
prevRace = pd.read_csv('/Volumes/My Passport for Mac/R/F1/2021/data/team_standing/team_standing_race21.csv')
prevRace = prevRace.rename(columns={'PTS': "pts_until_lastRace"})

# team_standing_raceX.csv. X每次+1
newRace = pd.read_csv('/Volumes/My Passport for Mac/R/F1/2021/data/team_standing/team_standing_race22.csv')

####
tm_sd = newRace.merge(prevRace[['Team', 'pts_until_lastRace']], how='left', left_on='Team', right_on='Team')
tm_sd['pts_this_week'] = tm_sd['PTS'] - tm_sd['pts_until_lastRace']
tm_sd['pts_until_lastRace'] = tm_sd['pts_until_lastRace'].fillna(0)


race = race.append(tm_sd)
race.to_csv('/Volumes/My Passport for Mac/R/F1/2021/data/team_standing.csv', index=False)
