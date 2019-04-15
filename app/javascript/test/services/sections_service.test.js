import { expect } from 'chai';
import { omit } from 'lodash';
import {
  buildSection,
  buildCategories,
  findBetterImageAndText,
  isEditable
} from '../../src/locomotive/editor/services/sections_service';

describe('locomotive/editor/services/sections_service', function() {

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

      expect(section.id).to.have.lengthOf(36);
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
