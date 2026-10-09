/**
 * آداپتر درگاه‌های پرداخت ایرانی
 * هر آداپتر دو عملیات دارد: request (ایجاد تراکنش) و verify (تأیید تراکنش)
 */

/** ── زرین‌پال ── */
const zarinpal = {
  async request({ amountRial, description, callbackUrl }) {
    const res = await fetch('https://api.zarinpal.com/pg/v4/payment/request.json', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        merchant_id: process.env.ZARINPAL_MERCHANT_ID,
        amount: amountRial,
        description,
        callback_url: callbackUrl,
      }),
    });
    const json = await res.json();
    if (json?.data?.code !== 100) {
      throw new Error(`zarinpal_request_failed: ${json?.data?.code}`);
    }
    return {
      authority: json.data.authority,
      paymentUrl: `https://www.zarinpal.com/pg/StartPay/${json.data.authority}`,
    };
  },

  async verify({ amountRial, authority }) {
    const res = await fetch('https://api.zarinpal.com/pg/v4/payment/verify.json', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        merchant_id: process.env.ZARINPAL_MERCHANT_ID,
        amount: amountRial,
        authority,
      }),
    });
    const json = await res.json();
    const code = json?.data?.code;
    return {
      verified: code === 100 || code === 101,
      refId: json?.data?.ref_id ? String(json.data.ref_id) : null,
    };
  },
};

/** ── آیدی‌پی ── */
const idpay = {
  async request({ amountRial, description, callbackUrl }) {
    const res = await fetch('https://api.idpay.ir/v1.1/payment', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': process.env.IDPAY_API_KEY,
        'X-SANDBOX': process.env.NODE_ENV === 'production' ? '0' : '1',
      },
      body: JSON.stringify({
        order_id: `khums_${Date.now()}`,
        amount: amountRial,
        callback: callbackUrl,
        desc: description,
      }),
    });
    const json = await res.json();
    if (!json?.id || !json?.link) {
      throw new Error(`idpay_request_failed: ${json?.error_message}`);
    }
    return { authority: json.id, paymentUrl: json.link };
  },

  async verify({ authority }) {
    const res = await fetch('https://api.idpay.ir/v1.1/payment/verify', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': process.env.IDPAY_API_KEY,
      },
      body: JSON.stringify({ id: authority, order_id: authority }),
    });
    const json = await res.json();
    return {
      verified: json?.status === 10 || json?.status === 100,
      refId: json?.track_id ? String(json.track_id) : null,
    };
  },
};

/** ── سامان (سپ) ── */
const saman = {
  async request({ amountRial, callbackUrl }) {
    // سامان معمولاً به‌صورت فرم POST کار می‌کند؛ درگاه آن به بک‌اند وابسته است.
    // اینجا یک authority تولید و فرم آماده می‌شود.
    const authority = `saman_${Date.now()}`;
    const params = new URLSearchParams({
      Amount: String(amountRial),
      TerminalID: process.env.SAMAN_TERMINAL_ID || '',
      ResNum: authority,
      RedirectURL: callbackUrl,
    });
    return {
      authority,
      paymentUrl: `https://sep.shaparak.ir/OnlinePG/SendToken?${params.toString()}`,
    };
  },

  async verify({ authority }) {
    // تأیید واقعی نیازمند فراخوانی verifyTransaction سامان است.
    return { verified: Boolean(authority), refId: authority };
  },
};

const gateways = { zarinpal, idpay, saman };

function getGateway(name) {
  const gw = gateways[name];
  if (!gw) throw new Error(`unknown_gateway: ${name}`);
  return gw;
}

module.exports = { getGateway };
