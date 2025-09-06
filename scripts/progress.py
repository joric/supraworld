# finding progress in supraworld save files
# could not filter by act1 yet

import json

data = json.load(open('SaveGame.json'))
playerStat = data['dynamicSaveData']['NamedData']['PlayerStat']

trueFlags = ['ItemIsTaken', 'bFound', 'Active', 'bPickedUp', 'bUnlocked', 'ItemIsTaken']
marked = set()

for s,o in data['dynamicSaveData']['ObjectData'].items():
    if any(o.get(tf) for tf in trueFlags):
        base = s.strip('"').split('.').pop()
        marked.add(base)

#print('--- marked items ---')
#for s in marked: print(s)

def members(prefix, name):
    res = set()
    o = playerStat.get(f'{prefix}.{name}')
    if not o:
        return res
    for s in o['ProgressMembers'][1:-1].split(','):
        base = s.strip('"').split('.').pop()
        res.add(base)
    return res

statNames = ['Secret','Present', 'Collectible.SolversGuide', 'GlitchingTicket',
    'SpawnerDestroyed','Collectible.Hay','Secret','Collectible.Rune', 'Collectible.SolversGuide']

for name in statNames:
    completed = members('CompletedProgress_Stats', name)
    total = members('TotalProgress_Stats', name)
    print(f'--- {name}: {len(completed)}/{len(total)} --- ')
    remaining = total - completed
    for s in remaining: print (s)
