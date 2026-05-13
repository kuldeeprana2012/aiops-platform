import json
import os
import requests

OLLAMA_URL = os.getenv('OLLAMA_URL', 'http://localhost:11434')


def analyze_logs(log_entries):
    prompt = (
        'You are an AIOps root cause investigator. Review the following log events and provide:\n'
        '1. probable root cause\n'
        '2. impacted service components\n'
        '3. immediate remediation steps\n'
        '4. whether this is a critical outage, degradation, or info event\n\n'
        f'Log events:\n{json.dumps(log_entries, indent=2)}'
    )

    payload = {
        'model': 'gpt-4o-mini',
        'messages': [
            {'role': 'system', 'content': 'You are an enterprise AIOps analyst.'},
            {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 500,
    }
    response = requests.post(f'{OLLAMA_URL}/v1/chat/completions', json=payload, timeout=30)
    response.raise_for_status()
    data = response.json()
    return data['choices'][0]['message']['content']


if __name__ == '__main__':
    import sys

    raw = sys.stdin.read()
    entries = json.loads(raw or '[]')
    print(analyze_logs(entries))
