import os
from celery import Celery
from kombu import Queue

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'celery_django.settings')

app = Celery('celery_django', include=['celery_django.tasks'])

app.config_from_object('django.conf:settings', namespace='CELERY')

app.autodiscover_tasks()

app.conf.task_default_queue = 'tarefas'
app.conf.task_queues = (
     Queue('tarefas', routing_key='default'),
)

if __name__ == '__main__':
    app.start()
