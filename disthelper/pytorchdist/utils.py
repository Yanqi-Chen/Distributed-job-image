import os


def get_dist_info():
	"""Get distributed task related information

	Args: 
		None

	Returns:
		A tuple contains 2 strings (host IP and port) or None if there exists
		NO port labeled "dist". 
		For example:

		('192.168.1.101', '4969')

	"""

	if 'QIZHI_DIST_HOST_AND_PORT' in os.environ:
		# Assume ipv4 host address
		info = os.environ['QIZHI_DIST_HOST_AND_PORT'].split('-')
		return tuple(info)
	print('Error: No port labeled "dist"')
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
