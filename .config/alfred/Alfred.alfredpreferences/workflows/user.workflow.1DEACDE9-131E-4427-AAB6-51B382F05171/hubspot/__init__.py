from .auth import *
from .bookmarks import *
from .github import *
from .deployables import *
from .singularity import *
from .blazar import *
from .package import *
from .jira import *
from .go import *
from .monitor_teams import *
from .monitor_deployables import *
from .monitor_systems import *
from .api_catalog import *
from .gates import *
from .docs import *

TOOLS = dict(bookmarks=Bookmarks,
             repo=GitHub,
             build=Blazar,
             blazar=Blazar,
             test=Tests,
             deploy=Deploy,
             deploys=Deploys,
             singularity=SingularityPROD,
             singularityqa=SingularityQA,
             jira=Jira,
             package=Package,
             appoptics=AppOpticsPROD,
             appopticsqa=AppOpticsQA,
             go=Go,
             tail=TailPROD,
             tailqa=TailQA,
             monitor_team=MonitorTeams,
             monitor_deployable=MonitorDeployablesPROD,
             monitor_deployable_qa=MonitorDeployablesQA,
             monitor_system=MonitorSystemsPROD,
             monitor_system_qa=MonitorSystemsQA,
             api=ApiCatalogPROD,
             apiqa=ApiCatalogQA,
             gates=GatesPROD,
             gatesqa=GatesQA,
             docs=Docs)
