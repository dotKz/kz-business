# kz-business

<a href="https://www.buymeacoffee.com/dotkz" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>


**Create your farming business**
- Create your business with /createbusiness
- Manage your employees with QBR-Management (need to rework)
- Choose your type of business (/business)
- Place your 4 points and start the work (QG / Harvest / Processing / Sale)
- (Admin) Use /setbusiness for setting player into business
- /setbusiness (Player ID) (ID of business) (Grade)


**Install  :** 
- Import SQL
- Add example item in qbr-core/shared/items.lua
- Replace qbr-core/server/export.lua with export.lua
- Replace last line of qbr-core/client/events.lua with replace-events.lua


**Requirement :**
- oxmysql
- qbr-core
- qbr-menu
- qbr-input
- qbr-inventory


**TODO for release (you can create pull request ;) ) :**
- Minimum distance between each point
- Implemented kz-cart (update needed)
- Translate
- Admin menu for business
- Check name when business is create
- Add business account (in rework of qbr-management)