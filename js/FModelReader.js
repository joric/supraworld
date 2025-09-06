// FModelReader.js, (c) Joric 2025
// loads data from FModel JSON export, returns GeoJSON
// you can use it to save to a file if needed
// requires three-onlymath.min.js

// GitHub doesn't allow files larger than 100Mb, so we use gzip

async function loadGzip(url, callback, batchSize = 16 * 1024 * 1024) {
  console.time('loading gzip');
  if (!('DecompressionStream' in window)) {
    console.error('DecompressionStream not supported.');
    return;
  }
  const response = await fetch(url);
  if (!response.ok) throw new Error('Network error: ' + response.status);
  const ds = new DecompressionStream('gzip');
  const decompressedStream = response.body.pipeThrough(ds);
  const reader = decompressedStream.getReader();
  const decoder = new TextDecoder();
  let result = '';
  let buffer = '';
  function pump() {
    reader.read().then(({ done, value }) => {
      if (done) {
        result += buffer + decoder.decode();
        console.timeEnd('loading gzip');
        callback(result);
        return;
      }
      buffer += decoder.decode(value, { stream: true });
      if (buffer.length >= batchSize) {
        result += buffer;
        buffer = '';
        setTimeout(pump, 0);
      } else {
        pump();
      }
    });
  }
  pump();
}



function markerLoader(data) {
  let area = 'Supraland';
  let areas = {};
  let outers = {};
  let meshes = {};
  let messengers = {};
  let targets = {};

  function getMatrix(o, matrix) {
    matrix = matrix || new THREE.Matrix4();
    if (p = o.Properties) {
      if (p.RelativeLocation) {
        //console.log(o, p.RelativeLocation);
        matrix.premultiply(locRotScale(getVec(p.RelativeLocation), getRot(p.RelativeRotation), getVec(p.RelativeScale3D, 1)));
      }
      for (parent of ['RootObject', 'RootComponent', 'DefaultSceneRoot', 'AttachParent']) {
        if ((node = p[parent]) && (s = node.ObjectName)) {
          let d = s.split("'")[1].split(':')[1].split('.')
          let key = d[1] + '.' + d[2];
          if (t = outers[key]) {
            return getMatrix(t, matrix);
          }
        }
      }
    }
    return matrix;
  }

  function getLocation(o) {
    let matrix = getMatrix(o);
    (m = areas[area]) && matrix.premultiply(m);
    return new THREE.Vector3().setFromMatrixPosition(matrix);
  }

  function getDirection(o) {
    let matrix = getMatrix(o);
    (m = areas[area]) && matrix.premultiply(m);
    return new THREE.Vector3().setFromMatrixColumn(matrix,2).normalize();
  }

  function locRotScale(loc, rot, scale) {
    let t = new THREE.Matrix4().makeTranslation(loc.x, loc.y, loc.z);
    let r = makeRotationFromEuler(rot);
    let s = new THREE.Matrix4().makeScale(scale.x, scale.y, scale.z);
    return new THREE.Matrix4().multiply(t).multiply(r).multiply(s);
  }

  function toRad(x) { return THREE.Math.degToRad(x); }
  function getVec(v,t) { return v ? new THREE.Vector3(v.X, v.Y, v.Z) : new THREE.Vector3(t,t,t); }
  function getRot(v) { return v ? new THREE.Vector3(toRad(v.Roll), toRad(v.Pitch), toRad(v.Yaw) ) : new THREE.Vector3() }
  function getQuat(v) { return v ? new THREE.Quaternion(v.X, v.Y, v.Z, v.W) : new THREE.Quaternion(); }

  function makeRotationFromEuler(r) {
    let matrix = new THREE.Matrix4().makeRotationFromEuler(new THREE.Euler(-r.x, -r.y, -r.z));
    let m = matrix.elements; // negate angles, flip rows/columns to match mathutils
    matrix.set(m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9], m[10], m[11], m[12], m[13], m[14], m[15]);
    return matrix;
  }

  for (const o of data) {
    let outer = o.Outer + '.' + o.Name;
    outers[outer] = o;
    if ((p = o.Properties) && (a = p.WorldAsset) && (n = a.AssetPathName) && (t = p.LevelTransform)) {
      let key = n.split('.').pop();
      let m = new THREE.Matrix4().compose(getVec(t.Translation, 0), getQuat(t.Rotation), new THREE.Vector3(1,1,1));
      areas[key] = m
    }
    if (o.Type=='StaticMeshComponent') meshes[o.Outer] = o;
    if (o.Type=='MessengerComponent') messengers[o.Outer] = o;
    if (o.Type=='SupraworldLaunchComponent_C') targets[o.Outer] = o;
  }

  let features = [];

  for (const o of data) {
    //if (!types[o.Type]) continue;
    if (!o.Type.endsWith('_C')) continue; // supraland filter

    let c = getLocation(o, area);

    if (c.x==0 && c.y==0 && c.z==0) continue;

    let feature = {'type': 'Feature', 'geometry': {'type': 'Point', 'coordinates': [c.x, c.y, c.z]}, 'properties': {'name': o.Name, 'type': o.Type}};

    const getObjectName = t => t.ObjectName.split("'")[1];
    const getAssetName = t => t.AssetPathName.split(".")[1];
    const getName = t => t.ObjectName ? getObjectName(t) : getAssetName(t);

    let prop = feature.properties;

    if (p=o.Properties) {

      if (p.Exists==false) prop.exists = false;
      if (p.bHidden==true) prop.hidden = true;

      for (const name of ['Pickup Class', 'CustomShopItem', 'InventoryItem']) {
        if (p[name]) {
          prop.spawns = getName(p[name]);
        }
      }

      if (p.RequiredAbilities) prop.abilities = p.RequiredAbilities;
      if (p.Area && p.Area.TagName) prop.area = p.Area.TagName;
      if (p.ProgressionGroup &&  p.ProgressionGroup.TagName) prop.progression = p.ProgressionGroup.TagName;

      if (((c = p.Color) || (c = p.Color_Initial) || (c = p.ButtonColor)) && typeof c === 'string') prop.color = c;

      const getString = t => t?.SourceString || (t && typeof t === 'object' && Object.values(t).map(getString).find(Boolean)) || null;
      if (p.CharacterTalk) prop.text = getString(p.CharacterTalk);

      if (p.Achievement?.TagName) prop.achievement = p.Achievement.TagName.split('.').pop();
    }

    if ((m = meshes[o.Name]) && (m.Properties && m.Properties.OverrideMaterials)) {
      for (const mat of m.Properties.OverrideMaterials) {
        if (mat) {
          prop.material = getObjectName(mat);
        }
      }
    }

    if ((m = messengers[o.Name]) && (s = m.Properties?.MessageEvents?.[0]?.TargetActor?.SubPathString)) {
      prop.actor = s.split('.').pop();
    }

    if ((m = targets[o.Name]) && (t = m.Properties?.TargetLocation)) {
      prop.target = [t.X, t.Y, t.Z];
      if (v = m.Properties?.Velocity) prop.velocity = v;
    }

    features.push(feature);
  }

  return features;
}

////////////////////////////////////////////////////////////////////////

if (typeof require !== 'undefined' && require.main === module) {
  const fs = require('fs');
  const zlib = require('zlib');
  const vm = require('vm');

  const code = fs.readFileSync('./three-onlymath.min.js', 'utf8');
  vm.runInThisContext(code);

  console.time('loading gzip');

  for (fname of [
    "../data/Supraworld.json.gz",
  ]) {
    zlib.gunzip(fs.readFileSync(fname), (err, buffer) => {
      console.timeEnd('loading gzip');
      if (err) throw err;
      let data = JSON.parse(buffer);
      let features = markerLoader(data);
      const json = JSON.stringify(features, null, 2);
      let outname = 'out.json';
      fs.writeFileSync(outname, json, 'utf8');
      console.log(`saved to ${outname} (${features.length} features)`);
    });
  }
}

