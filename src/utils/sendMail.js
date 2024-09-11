import resend from '../configs/resend.js';

async function sendMail(to, subject, html, from='Luma - Gamified Project Management <team@luma-gpm.com>') {
  const response = await resend.emails.send({
      from: from,
      to: to,
      subject: subject,
      html: html,
  });
    return response;
}

export default sendMail;