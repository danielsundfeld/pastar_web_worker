import os
import tempfile
import subprocess
from .celeryconfig import app

@app.task(bind=True)
def alinhar_sequencias(self, sequencias):

    (fd, sequences_file) = tempfile.mkstemp()
    with open(sequences_file, 'w') as file:
        for sequencia in sequencias:
            file.write(sequencia)

    stdout = subprocess.run(
        ['msa_pastar', sequences_file],
        stdout=subprocess.PIPE, encoding='utf8')
    os.remove(sequences_file)

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
