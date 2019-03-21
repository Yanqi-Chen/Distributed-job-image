import os

def get_ps_hosts():
	"""Get parameter servers information

	Args: 
		None

	Returns:
		A string contains all ps_server if labeled. 
		For example:

		'192.168.1.101:1,192.168.1.102:2'

	"""

	if 'QIZHI_TASK_ROLE_ps_server_HOST_LIST' in os.environ:
		return os.environ['QIZHI_TASK_ROLE_ps_server_HOST_LIST']
	print('Error: No taskrole named "ps_server"')
	return None

def get_worker_hosts():
	"""Get workers information

	Args: 
		None

	Returns:
		A string contains all workers if labeled. 
		For example:

		'192.168.1.101:1,192.168.1.102:2'

	"""

	if 'QIZHI_TASK_ROLE_worker_HOST_LIST' in os.environ:
		return os.environ['QIZHI_TASK_ROLE_worker_HOST_LIST']
	print('Error: No taskrole named "worker"')
	return None

def get_rank_info():
	"""Get rank information

	Args:
		None

	Returns:
		A tuple contains 2 integers. Current taskrole index 'rank' and number
		of current taskrole 'cnt'. Rank in [0,cnt). For example:

		(1, 3)

	"""
	rank = int(os.environ['QIZHI_TASK_INDEX'])
	cnt = int(os.environ['QIZHI_CURRENT_TASK_ROLE_TASK_COUNT'])
	return rank, cnt