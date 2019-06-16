const functions = require('firebase-functions');
const cors = require('cors');
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const fbAdmin = require('firebase-admin');
const uuid = require('uuid/v4');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


const {Storage} = require('@google-cloud/storage');
const gcconfig = {
    projectId:'flutter-sample-35082',
    keyFilename: 'flutter-sample.json',
};
// const gcs = require('@google-cloud/storage')(gcconfig);
const gcs = new Storage(gcconfig);

fbAdmin.initializeApp({
    credential: fbAdmin.credential.cert(require('./flutter-sample.json'))
});


exports.storeImage = functions.https.onRequest((req, res) => {
    return cors(req, res, () => {
        // VALIDATION
       console.log(`Req.Body: ${req.body}`);
        if(req.method !== 'POST'){
            return res.status(500).json({message: 'Not allowed.'});
        }
        if(!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')){
            return res.status(401).json({error: 'Unauthrized.'});
        }
        // STORES FILE
        let idToken;
        idToken = req.headers.authorization.split('Bearer ')[1];
        const busboy = new Busboy({headers: req.headers});
        let uploadData;
        let oldImagePath;
        // File temporary stored in
        busboy.on('file', (fieldname, file, filename, encoding, mimetype) => {
            const filePath = path.join(os.tmpdir(), filename);
            uploadData = {filePath: filePath, type: mimetype, name: filename};
            file.pipe(fs.createWriteStream(filePath));
        });
        // Read other data than files
        busboy.on('field', (fieldname, value) => {
            oldImagePath = decodeURIComponent(value);
        });
        // when busboy done reading incoming request
        busboy.on('finish', () => {
            const bucket = gcs.bucket('flutter-sample-35082.appspot.com');
            const id = uuid();
            let imagePath = 'images/' + id + '-' + uploadData.name;
            if(oldImagePath){
                imagePath = oldImagePath;
            }
            return fbAdmin.auth().verifyIdToken(idToken)
            .then(decodedToken => {
                return bucket.uploadData(uploadData.filePath, {
                    uploadType: 'media',
                    destination: imagePath,
                    metadata: {
                        metadata: {
                            contentType: uploadData.type,
                            firebaseStorageDownloadToken: id
                        }
                    }
                });
            })
            .then(() => {
                return res.statusCode(201).json({
                    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/' + bucket.name + '/o/' + encodeURIComponent(imagePath) + '?alt=media&token=' + id,
                    imagePath: imagePath
                });
            })
            .catch(error => {
                return res.statusCode(401).json({error: 'Unauthrized'});
            });
        });
        return busboy.end(req.rawBody);
    });
});
