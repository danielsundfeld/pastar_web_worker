import subprocess
from .celeryconfig import app

@app.task(bind=True)
def alinhar_sequencias(self, sequencias):

    path = '/tmp/sequencias.txt'
    with open(path, 'w') as file:
        for sequencia in sequencias:
            file.write(sequencia)

    stdout = subprocess.run(
        ['msa_pastar', path],
        stdout=subprocess.PIPE, encoding='utf8')

    result = {
        'task_id': self.request.id,
        'result': stdout.stdout,
            }

    return app.send_task(
        'save_database',
        args=[result],
        queue= 'resultados',
        kwargs={},
    )
