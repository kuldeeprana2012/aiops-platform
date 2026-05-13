from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)

SLACK_WEBHOOK_URL = os.getenv('SLACK_WEBHOOK_URL')
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN')
TELEGRAM_CHAT_ID = os.getenv('TELEGRAM_CHAT_ID')
OLLAMA_URL = os.getenv('OLLAMA_URL', 'http://localhost:11434')


def query_ollama(prompt: str) -> str:
    payload = {
        'model': 'gpt-4o-mini',
        'messages': [
            {'role': 'system', 'content': 'You are an enterprise-grade AIOps analyst.'},
            {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 400,
    }
    response = requests.post(f'{OLLAMA_URL}/v1/chat/completions', json=payload, timeout=30)
    response.raise_for_status()
    data = response.json()
    return data['choices'][0]['message']['content']


def send_slack(text: str):
    if not SLACK_WEBHOOK_URL:
        return
    requests.post(SLACK_WEBHOOK_URL, json={'text': text}, timeout=10)


def send_telegram(text: str):
    if not TELEGRAM_TOKEN or not TELEGRAM_CHAT_ID:
        return
    url = f'https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage'
    requests.post(url, json={'chat_id': TELEGRAM_CHAT_ID, 'text': text}, timeout=10)


@app.route('/alert', methods=['POST'])
def alert():
    payload = request.json or {}
    status = payload.get('status', 'unknown')
    common = payload.get('commonAnnotations', {})
    labels = payload.get('commonLabels', {})
    summary = common.get('summary', 'AIOps alert received')
    description = common.get('description', '')

    prompt = (
        f"Alert status: {status}\n"
        f"Summary: {summary}\n"
        f"Description: {description}\n"
        f"Labels: {labels}\n\n"
        "Analyze this incident. Provide a short root cause hypothesis, impacted components, suggested remediation actions, and severity classification."
    )

    try:
        analysis = query_ollama(prompt)
    except Exception as exc:
        error_message = f'AI analysis failed: {exc}'
        print(error_message)
        return jsonify({'status': 'error', 'message': error_message}), 500

    text = f'*{summary}*\n{description}\n\n*AI Analysis:*\n{analysis}'
    send_slack(text)
    send_telegram(text)

    return jsonify({'status': 'ok', 'analysis': analysis})


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
