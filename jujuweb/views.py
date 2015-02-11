from pyramid.response import Response
from pyramid.view import view_config


@view_config(route_name='home', renderer='templates/home.pt')
def home(request):
    return {}


@view_config(route_name='upload', renderer='json')
def upload(request):
    return {}
