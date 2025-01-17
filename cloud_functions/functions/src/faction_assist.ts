import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { sendNotificationToUser } from "./notification";

export const factionAssistGroup = {

    sendAssistMessage: functions.region('us-east4').https.onCall(async (data, context) => {

        const promises: Promise<any>[] = [];

        // Get user's faction from Firestore
        const callingUser = await admin
            .firestore()
            .collection("players")
            .doc(context.auth.uid)
            .get();

        // Return error code if user or faction is not found
        if (callingUser.data() === undefined) {
            functions.logger.info(`User not found`);
            return -1;
        }
        let faction = (callingUser.data().faction);
        if (callingUser.data().faction === undefined || callingUser.data().faction === 0) {
            functions.logger.info(`Call from ${callingUser.data().name} [${callingUser.data().playerId}]: faction not found`);
            return -1;
        }

        // Get all faction members that allow messages to be received
        const response = await admin
            .firestore()
            .collection("players")
            .where("active", "==", true)
            .where("faction", "==", faction)
            .where("factionAssistMessage", "==", true)
            .where("name", "!=", `${callingUser.data().name}`) // Not the requestor's own name
            .get();

        const factionMembers = response.docs.map((d) => d.data());
        if (factionMembers.length === 0) {
            functions.logger.info(`Call from ${callingUser.data().name} [${callingUser.data().playerId}]: 0 receptors`);
            // No one to notify
            return 0;
        };

        // Retrieve data from app call
        let attackId = data["attackId"].toString();

        let attackName = data["attackName"];
        if (attackName === "") {
            attackName = ` ID ${attackId}`;
        } else {
            attackName = ` ${data["attackName"]}`;
        }

        let attackLevel = data["attackLevel"];
        if (attackLevel === "") {
            attackLevel = "";
        } else {
            attackLevel = ` (level ${attackLevel})`;
        }

        let membersNotified = 0;
        for (const key of Array.from(factionMembers.keys())) {
            const thisMember = factionMembers[key];

            promises.push(
                sendNotificationToUser(
                    thisMember.token,
                    `Attack assist request!`,
                    `${callingUser.data().name} (level ${callingUser.data().level}) needs help attacking${attackName}${attackLevel}!`,
                    "notification_assist",
                    "#FF0000",
                    "Alerts assists",
                    "",
                    "",
                    attackId,
                    thisMember.vibration,
                    "sword_clash.aiff"
                )
            );

            membersNotified++;
        }

        functions.logger.info(`Call from ${callingUser.data().name} [${callingUser.data().playerId}]: ${membersNotified} receptors`);

        await Promise.all(promises);

        return membersNotified;

    }),
};