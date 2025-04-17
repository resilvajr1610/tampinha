import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const fcm = admin.messaging();

export const notificacaoPortal = functions.https.onRequest((req, res) => {

            if (req.query.apiKey?.toString() === 'master51') {
                const payload: admin.messaging.MessagingPayload = {
                    notification: {
                    body: req?.query?.mensagem?.toString(),
                    title: 'Tampinha Legal',
                    },
                       "data": {
                         "click_action": "FLUTTER_NOTIFICATION_CLICK",
                         "sound": "default",
                       }
                    };
                 fcm.sendToTopic('tampinhalegal', payload).then(()=>{
                    res.status(200).send({
                        message: 'Sucesso ao enviar a notificação.',
                    });
                 }).catch(()=>{
                     res.status(400).send({
                         message: 'Falha ao enviar a notificação.'
                     });
                 });
            }else{
                res.status(400).send({
                    error: 'apiKey incorreta.'
                });
            }
});