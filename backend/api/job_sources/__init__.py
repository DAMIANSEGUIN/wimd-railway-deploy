"""
Job Sources Interface for Mosaic 2.0
Provides standardized interface for different job data sources.
"""

from .base import JobPosting, JobSource
from .careerbuilder import CareerBuilderSource
from .dice import DiceSource
from .glassdoor import GlassdoorSource
from .greenhouse import GreenhouseSource
from .hackernews import HackerNewsSource
from .indeed import IndeedSource
from .linkedin import LinkedInSource
from .monster import MonsterSource
from .reddit import RedditSource
from .remoteok import RemoteOKSource
from .serpapi import SerpApiSource
from .weworkremotely import WeWorkRemotelySource
from .ziprecruiter import ZipRecruiterSource

__all__ = [
    "JobSource",
    "JobPosting",
    "GreenhouseSource",
    "SerpApiSource",
    "RedditSource",
    "IndeedSource",
    "LinkedInSource",
    "GlassdoorSource",
    "RemoteOKSource",
    "WeWorkRemotelySource",
    "DiceSource",
    "MonsterSource",
    "ZipRecruiterSource",
    "CareerBuilderSource",
    "HackerNewsSource",
]
