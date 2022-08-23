import pandas as pd
import numpy as np

lap_df = pd.DataFrame(columns=["lap"])
lap_df.loc[:, "lap"] = np.arange(59) # number of laps +1
lap_df = lap_df.iloc[np.repeat(np.arange(len(lap_df)), 20)]
lap_df = lap_df[(lap_df.lap != 0)]

pos_df = pd.DataFrame(columns=["position"])
pos_df.loc[:, "position"] = np.arange(21)
pos_df = pos_df.iloc[np.tile(np.arange(len(pos_df)), 58)] # change this to number of laps
pos_df = pos_df[(pos_df.position != 0)]

df = pd.concat([lap_df.reset_index(drop=True), pos_df.reset_index(drop=True)], axis=1)
df.columns = ['lap', 'position']

df['GP'] = 'Abu Dhabi'
df['driver_int'] = np.nan
df['driver'] = np.nan
df['team'] = np.nan
df = df[['GP', 'lap', 'position', 'driver_int', 'driver', 'team']]

df.to_csv('/Users/yuwong/Downloads/F1_2021_racePos_race22.csv', index=False)