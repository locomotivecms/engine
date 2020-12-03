import { expect } from 'chai';
import { omit } from 'lodash';
import {
  buildSection,
  buildCategories,
  findBetterImageAndText,
  findFromTextId,
  isEditable
} from '../../src/locomotive/editor/services/sections_service';

describe('locomotive/editor/services/sections_service', function() {
  let sectionIds = [{ id: 'site-header', uuid: 'b2' }];

  let content = { 
    site: {
      sectionsContent: {
        header: {
          id: 'site-header',
          blocks: [
            { type: 'page', id: '0' },
            { type: 'sub-page', id: '1' },
            { type: 'page', id: '6e8d235c-8d0e-4ef9-966a-ae20383f98ca' }
          ]
        }
      }
    },
    page: {
      sectionsContent: {
        hero_simple: {
          id: 'page-hero_simple',
          uuid: 'a1'
        }
      },
      sectionsDropzoneContent: [
        {
          id: 'dropzone-0',
          uuid: '42',
          blocks: [{}, { type: 'team', id: '1' }]
        },          
        { 
          id: 'dropzone-4906b3b6-c5f2-4b30-baeb-dd95e960bb17', type: 'team',
          uuid: '4906b3b6-c5f2-4b30-baeb-dd95e960bb17', 
          blocks: [
            { type: 'person', id: '6e8d235c-8d0e-4ef9-966a-ae20383f98ca' }, 
            { type: 'person', id: '1' }
          ] 
        },
      ]
    }
  }

  describe('#findFromTextId', function() {
    it('returns the section/block/input matching the text id [PAGE]', () => {
      const { sectionId, blockType, blockId, settingId } = findFromTextId('section-page-hero_simple.title', content, sectionIds);
      expect(sectionId).to.eq('a1');
      expect(blockType).to.eq(null);
      expect(blockId).to.eq(null);
      expect(settingId).to.eq('title');
    });

    it('returns the brand new section/block/input matching the text id [PAGE]', () => {
      const { sectionId, blockType, blockId, settingId } = findFromTextId('section-dropzone-4906b3b6-c5f2-4b30-baeb-dd95e960bb17.title', content, sectionIds);
      expect(sectionId).to.eq('4906b3b6-c5f2-4b30-baeb-dd95e960bb17');
      expect(blockType).to.eq(null);
      expect(blockId).to.eq(null);
      expect(settingId).to.eq('title');
    });    

    it('returns the section/block/input matching the text id [SITE]', () => {
      const { sectionId, blockId, blockType, settingId } = findFromTextId('section-site-header-block.0.text', content, sectionIds);
      expect(sectionId).to.eq('b2');
      expect(blockType).to.eq('page');
      expect(blockId).to.eq('0');
      expect(settingId).to.eq('text');
    });

    it('returns the new section/block/input matching the text id [SITE]', () => {
      const { sectionId, blockId, blockType, settingId } = findFromTextId('section-site-header-block.6e8d235c-8d0e-4ef9-966a-ae20383f98ca.text', content, sectionIds);
      expect(sectionId).to.eq('b2');
      expect(blockType).to.eq('page');
      expect(blockId).to.eq('6e8d235c-8d0e-4ef9-966a-ae20383f98ca');
      expect(settingId).to.eq('text');
    });

    it('returns the section/block/input matching the text id [DROPZONE]', () => {      
      const { sectionId, blockId, blockType, settingId } = findFromTextId('section-dropzone-0-block.1.name', content, sectionIds);
      expect(sectionId).to.eq('42');
      expect(blockType).to.eq('team');
      expect(blockId).to.eq('1');
      expect(settingId).to.eq('name');
    });

    it('returns the brand new section/block/input matching the text id [DROPZONE]', () => {
      const { sectionId, blockId, blockType, settingId } = findFromTextId('section-dropzone-4906b3b6-c5f2-4b30-baeb-dd95e960bb17-block.6e8d235c-8d0e-4ef9-966a-ae20383f98ca.name', content, sectionIds);
      expect(sectionId).to.eq('4906b3b6-c5f2-4b30-baeb-dd95e960bb17');
      expect(blockType).to.eq('person');
      expect(blockId).to.eq('6e8d235c-8d0e-4ef9-966a-ae20383f98ca');
      expect(settingId).to.eq('name');
    });
    
  });

  describe('#findBetterImageAndText', function() {

    it('does not return an image and a text if keep_icon and keep_text are true', function() {
      const content = { settings: { image: '/banner.png', body: '<b>Hello</b> world' } };
      const definition = {
        keep_icon: true,
        keep_name: true,
        settings: [{ id: 'image', type: 'image_picker' }, { id: 'body', type: 'text' }]
      };
      expect(findBetterImageAndText(content, definition)).to.include({ image: null, text: null });
    });

    it('returns the first image and text of the section', function() {
      const content = { settings: { logo: '/logo.png', image: '/banner.png', body: "<b>Hello</b>\n world" } };
      const definition = {
        settings: [{ id: 'image', type: 'image_picker' }, { id: 'body', type: 'text' }, { id: 'logo', type: 'image_picker' }]
      };
      expect(findBetterImageAndText(content, definition)).to.include({ image: '/banner.png', text: 'Hello world' });
    });

    it('returns the first image and text of all the blocks if the section has no settings', function() {
      const content = { settings: {}, blocks: [{ type: 'simple', settings: { image: '/banner.png', body: '<b>Hello</b> world' } }] };
      const definition = {
        settings: [],
        blocks: [
          {
            type: 'simple',
            settings: [{ id: 'image', type: 'image_picker' }, { id: 'body', type: 'text' }, { id: 'logo', type: 'image_picker' }]
          }
        ]
      };
      expect(findBetterImageAndText(content, definition)).to.include({ image: '/banner.png', text: 'Hello world' });
    });
  });

  describe('#buildSection', function() {

    it('should build a new section with default values from the preset', function() {
      const definitions = [
        {
          type: 'slideshow',
          presets: [
            {
              name:     'Simple',
              settings: { title: 'Hello world' },
              blocks:   []
            },
            {
              name:     'Creative',
              settings: { title: 'Awesome!' },
              blocks:   []
            }
          ]
        }
      ]
      const section = buildSection(definitions, 'slideshow', 1)

      expect(section.id).to.have.lengthOf(45);
      expect(section.uuid).to.have.lengthOf(36);

      expect(omit(section, ['id', 'uuid', 'anchor'])).to.eql({
        name:     'Creative',
        type:     'slideshow',
        settings: { title: 'Awesome!' },
        blocks:   [],
        source:   'dropzone'
      });

      // it shouldn't keep a reference to the original preset settings
      section.settings.title = 'Modified title';
      expect(definitions[0].presets[1].settings.title).to.eql('Awesome!');
    });

    it('should build a valid section even if the preset is incomplete', function() {
      const definitions = [{ type: 'slideshow', presets: [{ name: 'Simple' }] }];
      expect(omit(buildSection(definitions, 'slideshow', 0), ['id', 'uuid', 'anchor'])).to.eql({
        name:     'Simple',
        type:     'slideshow',
        settings: {},
        blocks:   [],
        source:   'dropzone'
      });
    });

    it('should fill the settings with default values (if present)', function() {
      const definitions = [
        {
          type: 'hero',
          settings: [
            {
              id:       'title',
              type:     'string',
              default:  'Hello world'
            }
          ],
          blocks: [
            {
              type:     'button',
              settings: [
                {
                  id:       'label',
                  type:     'text',
                  default:  'CTA'
                }
              ]
            }
          ],
          presets: [{ name: 'Simple', settings: { image: '/banner.png' }, blocks: [{ type: 'button' }, { type: 'button' }] }]
        }
      ];
      expect(omit(buildSection(definitions, 'hero', 0), ['id', 'uuid', 'anchor', 'blocks'])).to.eql({
        name: 'Simple',
        type: 'hero',
        settings: { title: 'Hello world', image: '/banner.png' },
        source: 'dropzone'
      });
      expect(buildSection(definitions, 'hero', 0).blocks.length).to.eq(2);

      expect(omit(buildSection(definitions, 'hero', 0).blocks[0], ['id'])).to.eql({
        'type': 'button', settings: { label: 'CTA' }
      });
    });

  });

  describe('#buildCategories()', function() {

    it('should return an empty array if no presets among the sections', function() {
      const definitions = [{ name: 'Header', settings: [] }];
      expect(buildCategories(definitions)).to.eql([]);
    });

    it('should return a category with 2 presets from one single section with 2 presets', function() {
      const definitions = [
        {
          name:     'Carousel',
          type:     'carousel',
          presets:  [
            { name: 'Simple', category: 'Category A' },
            { name: 'With video', category: 'Category A' }
          ]
        }
      ];
      expect(buildCategories(definitions)).to.eql([
        {
          id: 0,
          name: 'Category A',
          presets: [
            { id: 0, name: 'Simple', type: 'carousel', preset: 0 },
            { id: 1, name: 'With video', type: 'carousel', preset: 1 }
          ]
        }
      ]);
    });

    it('should return multiple categories', function() {
      const definitions = [
        {
          name:     'Carousel',
          type:     'carousel',
          presets:  [
            { name: 'With video', category: 'Category B' },
            { name: 'Simple', category: 'Category A' }
          ]
        },
        {
          type:     'text',
          presets:  [{ name: 'Double column', category: 'Category A' }]
        }
      ];
      expect(buildCategories(definitions)).to.eql([
        {
          id: 1,
          name: 'Category A',
          presets: [
            { id: 0, name: 'Double column', type: 'text', preset: 0 },
            { id: 1, name: 'Simple', type: 'carousel', preset: 1 }
          ]
        },
        {
          id: 0,
          name: 'Category B',
          presets: [
            { id: 0, name: 'With video', type: 'carousel', preset: 0 }
          ]
        }
      ]);
    });

  });

  describe('#isEditable', function() {

    it('returns true if the definition does not define blocks or settings', function() {
      const definition = {
        keep_icon:  true,
        keep_name:  true,
        settings:   []
      };
      expect(isEditable(definition)).to.equal(false);
    });

    it('returns true if the definition does not define blocks or settings', function() {
      const definition = {
        keep_icon:  true,
        keep_name:  true,
        settings:   [],
        blocks:     [
          {
            type:     'button',
            settings: [
              {
                id:       'label',
                type:     'text',
                default:  'CTA'
              }
            ]
          }
        ]
      };
      expect(isEditable(definition)).to.equal(true);
    });

  });

});
