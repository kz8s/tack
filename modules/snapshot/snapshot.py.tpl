import boto3


ec = boto3.client('ec2')

def snapshot(event, context):
    volumes = ec.describe_volumes(Filters=[{
      'Name': 'tag:KubernetesCluster',
      'Values': ['${ name }'], }])

    for vol in volumes.get('Volumes', []):
        snap = ec.create_snapshot(VolumeId=vol.get('VolumeId'))
        ec.create_tags(
            Resources=[snap.get('SnapshotId')],
            Tags=vol.get('Tags'))