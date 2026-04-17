// not really an UE5 reader just yet, rather a stub, reads supraworld entries
// joric, 2026

class UESaveObject {
  constructor(arrayData) {
    let dataview = new DataView(arrayData, arrayData.byteOffset, arrayData.byteLength);
    let strview = new TextDecoder("latin1").decode(dataview);

    const srchStr = '\0PersistentLevel.'
    const re_match = new RegExp(srchStr, 'gi');
    let m;

    this.Properties = [];
    this.Properties.push({"name": "ThingsToRemove", "value": {"value": []}});
    let o = this.Properties[0].value.value;

    while ((m = re_match.exec(strview)) != null) {
        const nameidx = m.index + srchStr.length;
        const namelen = dataview.getInt32(m.index+1-4, true) - srchStr.length + 1;
        const name = strview.slice(nameidx, nameidx + namelen);
        o.push(name);
    }
  }
}

if (typeof require !== 'undefined' && require.main === module) {
  for (fname of [
    "C:\\Users\\user\\AppData\\Local\\Supraworld\\Saved\\SaveGames\\Supraworld\\6\\SaveGame.sav"
  ])
  require('fs').readFile(fname, (err, buf) => {
    if (err) {
      console.log(err);
    } else {
      let loadedSave = new UE5SaveObject(buf.buffer);
      let s = JSON.stringify(loadedSave,null,2);
      require('fs').writeFileSync('save.json', s);
      console.log(s);
      /*
      for (o of loadedSave.Properties) {
        if (o.name == 'Player Position') {
          console.log(JSON.stringify(o, null, 2));
        }
      }
      */
    }
  })
}
