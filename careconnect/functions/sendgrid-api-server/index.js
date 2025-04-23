require('dotenv').config();  // ✅ Load .env variables

const cron = require('node-cron');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');
const serviceAccount = require('./careconnect-386ae-firebase-adminsdk-fbsvc-6eb0e397d2.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();

// Set up SendGrid API Key
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// Cron job runs every day at 7 AM
cron.schedule('* * * * *', async () => {

    console.log('Running cron job...');

    // Get the date for tomorrow
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1); // Add one day to the current date
    tomorrow.setHours(0, 0, 0, 0); // Set the time to midnight to start the check from midnight of tomorrow

    const endOfTomorrow = new Date(tomorrow);
    endOfTomorrow.setHours(23, 59, 59, 999); // Set the time to 23:59:59 to cover the whole day

    try {
        // Fetch users from Firestore
        const usersSnapshot = await db.collection('users').get();

        for (const userDoc of usersSnapshot.docs) {
            const uid = userDoc.id;
            const appointmentsRef = db
                .collection('users')
                .doc(uid)
                .collection('appointments');

            // Query for appointments scheduled for tomorrow
            const appointmentsSnapshot = await appointmentsRef
                .where('date', '>=', admin.firestore.Timestamp.fromDate(tomorrow))
                .where('date', '<=', admin.firestore.Timestamp.fromDate(endOfTomorrow))
                .get();

            for (const doc of appointmentsSnapshot.docs) {
                const appointment = doc.data();
                const email = userDoc.data().email;
                if (!email) continue; // Skip if the email is not available

                // Send reminder email
                try {
                    await sgMail.send({
                        to: email,
                        from: 'careconnect48@gmail.com', // Use a verified SendGrid sender email
                        subject: `Appointment Reminder for ${appointment.doctorName}`,
                        html: `
                            <h2>Reminder: Doctor Appointment</h2>
                            <p><strong>Doctor:</strong> ${appointment.doctorName}</p>
                            <p><strong>Purpose:</strong> ${appointment.purpose}</p>
                            <p><strong>Date:</strong> ${appointment.date.toDate().toLocaleDateString()}</p>
                            <p><strong>Time:</strong> ${appointment.time}</p>
                            <p><strong>Prerequisites:</strong> ${appointment.prerequisites}</p>
                        `,
                    });

                    console.log(`Email sent to ${email} for appointment with ${appointment.doctorName}`);
                } catch (error) {
                    console.error(`Error sending email to ${email}:`, error.response.body);
                }
            }
        }
    } catch (error) {
        console.error('Error sending reminders:', error);
    }
});
