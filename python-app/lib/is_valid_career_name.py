from control_variables import VALID_CAREER_INITIALS, VALID_CAREER_INSCRIPTION_MONTHS, VALID_CAREER_SHIFTS

import re

def is_valid_career_name(name: str) -> bool:
    return re.match(
        pattern=f'({"|".join(VALID_CAREER_INITIALS)})\\d\\d({"|".join(VALID_CAREER_INSCRIPTION_MONTHS)})({"|".join(VALID_CAREER_SHIFTS)})-\\d\\d',
        flags=re.IGNORECASE,
        string=name
        ) is not None
