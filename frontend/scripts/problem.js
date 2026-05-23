let isExpanded = true;
const body = document.body;
const expanderInstructions = document.getElementsByClassName("expansion-instruction")[0];
const expandArrow = document.getElementsByClassName("expand-arrow")[0];
const expander = document.getElementsByClassName("problem-title-container")[0];
const problemDescription = document.getElementsByClassName("problem-description")[0];

const expandedAreas = `
  "header              header"
  "problem-title       problem-title"
  "problem-description problem-description"
  "editor              shaderCanvas"
`;

const collapsedAreas = `
  "header              header"
  "problem-title       problem-title"
  "editor              shaderCanvas"
`;

function toggleExpand() {
    if (isExpanded) {
        body.style.gridTemplateAreas = collapsedAreas;
        if (expanderInstructions) expanderInstructions.textContent = "Expand";
        if (expandArrow) expandArrow.style.transform = "rotate(0deg)";
        if (expander) expander.style.borderBottom = "1px solid #DDD";
        if (problemDescription) problemDescription.style.display = "none";
        isExpanded = false;
    } else {
        body.style.gridTemplateAreas = expandedAreas;
        if (expanderInstructions) expanderInstructions.textContent = "Collapse";
        if (expandArrow) expandArrow.style.transform = "rotate(90deg)";
        if (expander) expander.style.borderBottom = "none";
        if (problemDescription) problemDescription.style.display = "block";
        isExpanded = true;
    }
}
